"""
Camera Integration - Phase 2 Feature
RTSP video streaming with motion detection and analytics
Derived from Begin Reference System
"""

import logging
import asyncio
import cv2
import numpy as np
import json
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
from decimal import Decimal
import threading
import queue
import subprocess
import os
from collections import defaultdict

logger = logging.getLogger(__name__)

from ..common import models

class CameraIntegrationService:
    """Advanced camera integration with RTSP streaming and motion detection"""
    
    def __init__(self, db: Session):
        self.db = db
        self.cameras = {}
        self.streams = {}
        self.motion_detectors = {}
        self.recording_threads = {}
        self.frame_queues = defaultdict(queue.Queue)
        
        # Camera configuration
        self.camera_configs = {
            'resolution': (1920, 1080),
            'fps': 30,
            'codec': 'H264',
            'bitrate': 2000000,  # 2 Mbps
            'motion_threshold': 0.3,
            'motion_area_threshold': 0.05  # 5% of frame area
        }

    async def register_camera(self, camera_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Register new IP camera"""
        try:
            # Create camera record
            camera = models.IPCamera(
                camera_id=camera_data['camera_id'],
                camera_name=camera_data['camera_name'],
                location=camera_data.get('location'),
                rtsp_url=camera_data['rtsp_url'],
                username=camera_data.get('username'),
                password=camera_data.get('password'),
                camera_type=camera_data.get('camera_type', 'fixed'),
                resolution_width=camera_data.get('resolution_width', 1920),
                resolution_height=camera_data.get('resolution_height', 1080),
                fps=camera_data.get('fps', 30),
                field_of_view=camera_data.get('field_of_view', 90),
                night_vision=camera_data.get('night_vision', False),
                ptz_enabled=camera_data.get('ptz_enabled', False),
                recording_enabled=camera_data.get('recording_enabled', True),
                motion_detection_enabled=camera_data.get('motion_detection_enabled', True),
                configuration_json=json.dumps(camera_data.get('configuration', {})),
                status='active',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(camera)
            self.db.commit()
            
            # Store in memory
            self.cameras[camera.camera_id] = camera
            
            # Initialize camera stream
            await self._initialize_camera_stream(camera.camera_id)
            
            # Start motion detection if enabled
            if camera.motion_detection_enabled:
                await self._start_motion_detection(camera.camera_id)
            
            # Start recording if enabled
            if camera.recording_enabled:
                await self._start_recording(camera.camera_id)
            
            return {
                "success": True,
                "camera_id": camera.camera_id,
                "camera_name": camera.camera_name,
                "status": "registered",
                "stream_url": await self._get_stream_url(camera.camera_id),
                "message": "Camera registered successfully"
            }
            
        except Exception as e:
            logger.error(f"Error registering camera: {e}")
            self.db.rollback()
            return {"error": "Camera registration failed"}

    async def start_camera_stream(self, camera_id: str, tenant_id: str = "default") -> Dict[str, Any]:
        """Start RTSP stream for camera"""
        try:
            if camera_id not in self.cameras:
                return {"error": "Camera not found"}
            
            camera = self.cameras[camera_id]
            
            # Initialize OpenCV capture
            cap = cv2.VideoCapture(camera.rtsp_url)
            
            if not cap.isOpened():
                return {"error": "Failed to connect to camera"}
            
            # Set camera properties
            cap.set(cv2.CAP_PROP_FRAME_WIDTH, camera.resolution_width)
            cap.set(cv2.CAP_PROP_FRAME_HEIGHT, camera.resolution_height)
            cap.set(cv2.CAP_PROP_FPS, camera.fps)
            
            self.streams[camera_id] = cap
            
            # Start streaming thread
            stream_thread = threading.Thread(
                target=self._stream_frames,
                args=(camera_id,),
                daemon=True
            )
            stream_thread.start()
            
            # Update camera status
            camera.status = 'streaming'
            camera.last_seen = datetime.utcnow()
            self.db.commit()
            
            return {
                "success": True,
                "camera_id": camera_id,
                "stream_url": await self._get_stream_url(camera_id),
                "resolution": f"{camera.resolution_width}x{camera.resolution_height}",
                "fps": camera.fps,
                "message": "Camera stream started"
            }
            
        except Exception as e:
            logger.error(f"Error starting camera stream: {e}")
            return {"error": "Stream start failed"}

    async def detect_motion(self, camera_id: str, sensitivity: float = 0.3, 
                          tenant_id: str = "default") -> Dict[str, Any]:
        """Configure and start motion detection"""
        try:
            if camera_id not in self.cameras:
                return {"error": "Camera not found"}
            
            camera = self.cameras[camera_id]
            
            # Configure motion detection
            motion_config = {
                'sensitivity': sensitivity,
                'min_area': 500,  # Minimum contour area
                'blur_kernel': 21,
                'threshold_value': 25,
                'dilation_iterations': 2
            }
            
            # Start motion detection thread
            motion_thread = threading.Thread(
                target=self._motion_detection_loop,
                args=(camera_id, motion_config),
                daemon=True
            )
            motion_thread.start()
            
            self.motion_detectors[camera_id] = {
                'thread': motion_thread,
                'config': motion_config,
                'active': True
            }
            
            # Update camera
            camera.motion_detection_enabled = True
            camera.configuration_json = json.dumps({
                **json.loads(camera.configuration_json or '{}'),
                'motion_detection': motion_config
            })
            self.db.commit()
            
            return {
                "success": True,
                "camera_id": camera_id,
                "motion_detection": "enabled",
                "sensitivity": sensitivity,
                "message": "Motion detection started"
            }
            
        except Exception as e:
            logger.error(f"Error starting motion detection: {e}")
            return {"error": "Motion detection failed"}

    async def start_recording(self, camera_id: str, recording_type: str = "continuous",
                            duration_minutes: int = 60, tenant_id: str = "default") -> Dict[str, Any]:
        """Start camera recording"""
        try:
            if camera_id not in self.cameras:
                return {"error": "Camera not found"}
            
            camera = self.cameras[camera_id]
            
            # Create recording configuration
            recording_config = {
                'type': recording_type,
                'duration_minutes': duration_minutes,
                'output_path': f"recordings/{camera_id}",
                'segment_duration': 300,  # 5 minutes per segment
                'codec': 'mp4',
                'quality': 'high'
            }
            
            # Ensure output directory exists
            os.makedirs(recording_config['output_path'], exist_ok=True)
            
            # Start recording thread
            recording_thread = threading.Thread(
                target=self._recording_loop,
                args=(camera_id, recording_config),
                daemon=True
            )
            recording_thread.start()
            
            self.recording_threads[camera_id] = {
                'thread': recording_thread,
                'config': recording_config,
                'active': True,
                'start_time': datetime.utcnow()
            }
            
            # Update camera
            camera.recording_enabled = True
            camera.configuration_json = json.dumps({
                **json.loads(camera.configuration_json or '{}'),
                'recording': recording_config
            })
            self.db.commit()
            
            return {
                "success": True,
                "camera_id": camera_id,
                "recording_type": recording_type,
                "duration_minutes": duration_minutes,
                "output_path": recording_config['output_path'],
                "message": "Recording started"
            }
            
        except Exception as e:
            logger.error(f"Error starting recording: {e}")
            return {"error": "Recording start failed"}

    async def get_camera_feed(self, camera_id: str, format: str = "mjpeg", 
                           tenant_id: str = "default") -> Dict[str, Any]:
        """Get camera feed URL and metadata"""
        try:
            if camera_id not in self.cameras:
                return {"error": "Camera not found"}
            
            camera = self.cameras[camera_id]
            
            # Get stream URL based on format
            if format == "mjpeg":
                stream_url = f"http://localhost:8080/stream/{camera_id}/mjpeg"
            elif format == "rtsp":
                stream_url = camera.rtsp_url
            elif format == "hls":
                stream_url = f"http://localhost:8080/stream/{camera_id}/playlist.m3u8"
            else:
                stream_url = f"http://localhost:8080/stream/{camera_id}/mjpeg"
            
            return {
                "success": True,
                "camera_id": camera_id,
                "camera_name": camera.camera_name,
                "location": camera.location,
                "stream_url": stream_url,
                "format": format,
                "resolution": f"{camera.resolution_width}x{camera.resolution_height}",
                "fps": camera.fps,
                "status": camera.status,
                "last_seen": camera.last_seen.isoformat() if camera.last_seen else None
            }
            
        except Exception as e:
            logger.error(f"Error getting camera feed: {e}")
            return {"error": "Feed retrieval failed"}

    async def get_motion_events(self, camera_id: Optional[str] = None, start_date: Optional[str] = None,
                             end_date: Optional[str] = None, tenant_id: str = "default") -> Dict[str, Any]:
        """Get motion detection events"""
        try:
            # Build query
            query = self.db.query(models.MotionEvent).filter(
                models.MotionEvent.tenant_id == tenant_id
            )
            
            if camera_id:
                query = query.filter(models.MotionEvent.camera_id == camera_id)
            
            if start_date:
                start_dt = datetime.strptime(start_date, '%Y-%m-%d')
                query = query.filter(models.MotionEvent.event_time >= start_dt)
            
            if end_date:
                end_dt = datetime.strptime(end_date, '%Y-%m-%d')
                query = query.filter(models.MotionEvent.event_time <= end_dt)
            
            events = query.order_by(models.MotionEvent.event_time.desc()).limit(100).all()
            
            return {
                "success": True,
                "events": [
                    {
                        "id": event.id,
                        "camera_id": event.camera_id,
                        "event_time": event.event_time.isoformat(),
                        "confidence": event.confidence,
                        "bounding_boxes": json.loads(event.bounding_boxes_json) if event.bounding_boxes_json else [],
                        "snapshot_path": event.snapshot_path,
                        "video_path": event.video_path,
                        "duration_seconds": event.duration_seconds
                    }
                    for event in events
                ],
                "total_events": len(events)
            }
            
        except Exception as e:
            logger.error(f"Error getting motion events: {e}")
            return {"error": "Motion events retrieval failed"}

    async def get_camera_analytics(self, start_date: str, end_date: str, 
                                 tenant_id: str = "default") -> Dict[str, Any]:
        """Get camera analytics and insights"""
        try:
            start_dt = datetime.strptime(start_date, '%Y-%m-%d')
            end_dt = datetime.strptime(end_date, '%Y-%m-%d')
            
            # Get camera statistics
            camera_stats = await self._get_camera_statistics(start_dt, end_dt, tenant_id)
            
            # Get motion analytics
            motion_analytics = await self._get_motion_analytics(start_dt, end_dt, tenant_id)
            
            # Get recording analytics
            recording_analytics = await self._get_recording_analytics(start_dt, end_dt, tenant_id)
            
            # Get storage analytics
            storage_analytics = await self._get_storage_analytics(tenant_id)
            
            return {
                "period": {"start": start_date, "end": end_date},
                "camera_statistics": camera_stats,
                "motion_analytics": motion_analytics,
                "recording_analytics": recording_analytics,
                "storage_analytics": storage_analytics
            }
            
        except Exception as e:
            logger.error(f"Error getting camera analytics: {e}")
            return {"error": "Camera analytics retrieval failed"}

    async def control_camera(self, camera_id: str, command: str, parameters: Dict[str, Any],
                          tenant_id: str = "default") -> Dict[str, Any]:
        """Control PTZ camera functions"""
        try:
            if camera_id not in self.cameras:
                return {"error": "Camera not found"}
            
            camera = self.cameras[camera_id]
            
            if not camera.ptz_enabled:
                return {"error": "Camera does not support PTZ controls"}
            
            # Execute PTZ command
            result = await self._execute_ptz_command(camera_id, command, parameters)
            
            # Log command
            command_log = models.CameraCommand(
                camera_id=camera_id,
                command=command,
                parameters_json=json.dumps(parameters),
                status='executed',
                executed_at=datetime.utcnow(),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(command_log)
            self.db.commit()
            
            return {
                "success": True,
                "camera_id": camera_id,
                "command": command,
                "parameters": parameters,
                "result": result,
                "message": "Camera command executed successfully"
            }
            
        except Exception as e:
            logger.error(f"Error controlling camera: {e}")
            return {"error": "Camera control failed"}

    # Streaming and Processing Methods
    def _stream_frames(self, camera_id: str):
        """Stream frames from camera"""
        try:
            cap = self.streams.get(camera_id)
            if not cap:
                return
            
            while True:
                ret, frame = cap.read()
                if not ret:
                    logger.warning(f"Failed to read frame from camera {camera_id}")
                    break
                
                # Add frame to queue for processing
                if not self.frame_queues[camera_id].full():
                    self.frame_queues[camera_id].put(frame)
                
                # Small delay to control frame rate
                cv2.waitKey(33)  # ~30 FPS
                
        except Exception as e:
            logger.error(f"Error streaming frames for camera {camera_id}: {e}")

    def _motion_detection_loop(self, camera_id: str, config: Dict):
        """Motion detection processing loop"""
        try:
            background_subtractor = cv2.createBackgroundSubtractorMOG2(
                detectShadows=True,
                varThreshold=config['threshold_value']
            )
            
            while True:
                if self.frame_queues[camera_id].empty():
                    continue
                
                frame = self.frame_queues[camera_id].get()
                
                # Convert to grayscale
                gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                
                # Apply background subtraction
                fg_mask = background_subtractor.apply(gray)
                
                # Apply morphological operations
                kernel = np.ones((config['blur_kernel'], config['blur_kernel']), np.uint8)
                fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, kernel)
                fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_DILATE, kernel, 
                                         iterations=config['dilation_iterations'])
                
                # Find contours
                contours, _ = cv2.findContours(fg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
                
                # Filter contours by area
                motion_detected = False
                bounding_boxes = []
                
                for contour in contours:
                    area = cv2.contourArea(contour)
                    if area > config['min_area']:
                        x, y, w, h = cv2.boundingRect(contour)
                        bounding_boxes.append({
                            'x': int(x), 'y': int(y),
                            'width': int(w), 'height': int(h),
                            'area': float(area)
                        })
                        motion_detected = True
                
                # If motion detected, save event
                if motion_detected:
                    asyncio.run(self._save_motion_event(camera_id, frame, bounding_boxes, config))
                
                # Small delay
                cv2.waitKey(100)
                
        except Exception as e:
            logger.error(f"Error in motion detection loop for camera {camera_id}: {e}")

    def _recording_loop(self, camera_id: str, config: Dict):
        """Recording loop for camera"""
        try:
            cap = self.streams.get(camera_id)
            if not cap:
                return
            
            # Setup video writer
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            output_path = config['output_path']
            
            segment_start = datetime.utcnow()
            segment_filename = f"{output_path}/{camera_id}_{segment_start.strftime('%Y%m%d_%H%M%S')}.mp4"
            
            # Get frame size
            ret, frame = cap.read()
            if not ret:
                return
            
            frame_size = (frame.shape[1], frame.shape[0])
            fps = self.cameras[camera_id].fps
            
            out = cv2.VideoWriter(segment_filename, fourcc, fps, frame_size)
            
            while True:
                ret, frame = cap.read()
                if not ret:
                    break
                
                # Write frame
                out.write(frame)
                
                # Check if segment duration exceeded
                if (datetime.utcnow() - segment_start).total_seconds() >= config['segment_duration']:
                    out.release()
                    
                    # Start new segment
                    segment_start = datetime.utcnow()
                    segment_filename = f"{output_path}/{camera_id}_{segment_start.strftime('%Y%m%d_%H%M%S')}.mp4"
                    out = cv2.VideoWriter(segment_filename, fourcc, fps, frame_size)
                
                # Check if recording should stop
                if (datetime.utcnow() - self.recording_threads[camera_id]['start_time']).total_seconds() >= config['duration_minutes'] * 60:
                    break
                
                cv2.waitKey(33)
            
            out.release()
            
        except Exception as e:
            logger.error(f"Error in recording loop for camera {camera_id}: {e}")

    async def _save_motion_event(self, camera_id: str, frame: np.ndarray, 
                               bounding_boxes: List[Dict], config: Dict):
        """Save motion detection event"""
        try:
            # Calculate motion confidence
            total_area = sum(box['area'] for box in bounding_boxes)
            frame_area = frame.shape[0] * frame.shape[1]
            motion_percentage = total_area / frame_area
            
            confidence = min(1.0, motion_percentage / self.camera_configs['motion_area_threshold'])
            
            # Save snapshot
            timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
            snapshot_path = f"motion_snapshots/{camera_id}_{timestamp}.jpg"
            os.makedirs("motion_snapshots", exist_ok=True)
            cv2.imwrite(snapshot_path, frame)
            
            # Create motion event record
            motion_event = models.MotionEvent(
                camera_id=camera_id,
                event_time=datetime.utcnow(),
                confidence=confidence,
                bounding_boxes_json=json.dumps(bounding_boxes),
                snapshot_path=snapshot_path,
                video_path=None,  # Would be set if recording
                duration_seconds=5.0,  # Default duration
                tenant_id=self.cameras[camera_id].tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(motion_event)
            self.db.commit()
            
            logger.info(f"Motion event saved for camera {camera_id} with confidence {confidence:.2f}")
            
        except Exception as e:
            logger.error(f"Error saving motion event: {e}")

    # Helper Methods
    async def _initialize_camera_stream(self, camera_id: str):
        """Initialize camera stream"""
        try:
            # This would be called during camera registration
            # Actual stream initialization happens in start_camera_stream
            pass
        except Exception as e:
            logger.error(f"Error initializing camera stream: {e}")

    async def _start_motion_detection(self, camera_id: str):
        """Start motion detection for camera"""
        try:
            camera = self.cameras[camera_id]
            await self.detect_motion(camera_id, 0.3, camera.tenant_id)
        except Exception as e:
            logger.error(f"Error starting motion detection: {e}")

    async def _start_recording(self, camera_id: str):
        """Start recording for camera"""
        try:
            camera = self.cameras[camera_id]
            await self.start_recording(camera_id, "continuous", 60, camera.tenant_id)
        except Exception as e:
            logger.error(f"Error starting recording: {e}")

    async def _get_stream_url(self, camera_id: str) -> str:
        """Get streaming URL for camera"""
        return f"http://localhost:8080/stream/{camera_id}/mjpeg"

    async def _execute_ptz_command(self, camera_id: str, command: str, parameters: Dict) -> Dict:
        """Execute PTZ command on camera"""
        try:
            # This would integrate with actual PTZ control API
            # For now, return mock response
            
            if command == "pan":
                direction = parameters.get('direction', 'right')
                speed = parameters.get('speed', 50)
                return {"command": "pan", "direction": direction, "speed": speed, "executed": True}
            elif command == "tilt":
                direction = parameters.get('direction', 'up')
                speed = parameters.get('speed', 50)
                return {"command": "tilt", "direction": direction, "speed": speed, "executed": True}
            elif command == "zoom":
                direction = parameters.get('direction', 'in')
                speed = parameters.get('speed', 50)
                return {"command": "zoom", "direction": direction, "speed": speed, "executed": True}
            elif command == "preset":
                preset_id = parameters.get('preset_id')
                return {"command": "preset", "preset_id": preset_id, "executed": True}
            else:
                return {"error": "Unknown PTZ command"}
                
        except Exception as e:
            logger.error(f"Error executing PTZ command: {e}")
            return {"error": "PTZ command execution failed"}

    async def _get_camera_statistics(self, start_dt: datetime, end_dt: datetime, tenant_id: str) -> Dict:
        """Get camera statistics"""
        try:
            cameras = self.db.query(models.IPCamera).filter(
                models.IPCamera.tenant_id == tenant_id
            ).all()
            
            stats = {}
            for camera in cameras:
                # Get uptime (simplified)
                uptime_percentage = 95.0  # Default
                
                # Get motion events count
                motion_count = self.db.query(models.MotionEvent).filter(
                    and_(
                        models.MotionEvent.camera_id == camera.camera_id,
                        models.MotionEvent.event_time >= start_dt,
                        models.MotionEvent.event_time <= end_dt
                    )
                ).count()
                
                stats[camera.camera_id] = {
                    "camera_name": camera.camera_name,
                    "location": camera.location,
                    "status": camera.status,
                    "uptime_percentage": uptime_percentage,
                    "motion_events": motion_count,
                    "recording_enabled": camera.recording_enabled,
                    "motion_detection_enabled": camera.motion_detection_enabled
                }
            
            return stats
            
        except Exception as e:
            logger.error(f"Error getting camera statistics: {e}")
            return {}

    async def _get_motion_analytics(self, start_dt: datetime, end_dt: datetime, tenant_id: str) -> Dict:
        """Get motion analytics"""
        try:
            motion_events = self.db.query(models.MotionEvent).filter(
                and_(
                    models.MotionEvent.event_time >= start_dt,
                    models.MotionEvent.event_time <= end_dt,
                    models.MotionEvent.tenant_id == tenant_id
                )
            ).all()
            
            if not motion_events:
                return {"total_events": 0}
            
            # Group by hour
            hourly_events = defaultdict(int)
            confidence_scores = []
            
            for event in motion_events:
                hour = event.event_time.hour
                hourly_events[hour] += 1
                confidence_scores.append(event.confidence)
            
            return {
                "total_events": len(motion_events),
                "events_per_hour": dict(hourly_events),
                "average_confidence": sum(confidence_scores) / len(confidence_scores),
                "peak_hour": max(hourly_events.items(), key=lambda x: x[1])[0] if hourly_events else None,
                "events_per_day": len(motion_events) / ((end_dt - start_dt).days or 1)
            }
            
        except Exception as e:
            logger.error(f"Error getting motion analytics: {e}")
            return {}

    async def _get_recording_analytics(self, start_dt: datetime, end_dt: datetime, tenant_id: str) -> Dict:
        """Get recording analytics"""
        try:
            # This would analyze actual recording files
            # For now, return mock data
            
            return {
                "total_recordings": 150,
                "total_duration_hours": 720,
                "average_file_size_mb": 250,
                "storage_used_gb": 37.5,
                "recordings_per_day": 5,
                "recording_quality": "high"
            }
            
        except Exception as e:
            logger.error(f"Error getting recording analytics: {e}")
            return {}

    async def _get_storage_analytics(self, tenant_id: str) -> Dict:
        """Get storage analytics"""
        try:
            # This would check actual disk usage
            # For now, return mock data
            
            return {
                "total_storage_gb": 1000,
                "used_storage_gb": 450,
                "available_storage_gb": 550,
                "usage_percentage": 45.0,
                "recordings_storage_gb": 350,
                "snapshots_storage_gb": 100,
                "estimated_days_remaining": 30
            }
            
        except Exception as e:
            logger.error(f"Error getting storage analytics: {e}")
            return {}
