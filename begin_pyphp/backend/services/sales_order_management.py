"""
Sales Order Management - Phase 4 Feature
Comprehensive sales order processing, inventory management, and customer relations
Derived from Begin Reference System
"""

import logging
import asyncio
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
import json
from decimal import Decimal

logger = logging.getLogger(__name__)

from ..common import models

class SalesOrderManagementService:
    """Advanced sales order management and customer relationship system"""
    
    def __init__(self, db: Session):
        self.db = db
        self.order_statuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled']
        self.payment_statuses = ['pending', 'paid', 'partial', 'overdue', 'refunded']

    async def create_sales_order(self, order_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Create new sales order with inventory validation"""
        try:
            # Generate order number
            order_number = await self._generate_order_number(tenant_id)
            
            # Validate customer
            customer_id = order_data.get('customer_id')
            if customer_id:
                customer = self.db.query(models.Customer).filter(
                    and_(
                        models.Customer.id == customer_id,
                        models.Customer.tenant_id == tenant_id
                    )
                ).first()
                if not customer:
                    return {"error": "Customer not found"}
            
            # Create sales order
            sales_order = models.SalesOrder(
                order_number=order_number,
                customer_id=customer_id,
                order_date=datetime.strptime(order_data['order_date'], '%Y-%m-%d').date() if isinstance(order_data.get('order_date'), str) else order_data.get('order_date', datetime.utcnow().date()),
                delivery_date=datetime.strptime(order_data['delivery_date'], '%Y-%m-%d').date() if isinstance(order_data.get('delivery_date'), str) else order_data.get('delivery_date'),
                order_type=order_data.get('order_type', 'standard'),
                priority=order_data.get('priority', 'normal'),
                status='pending',
                payment_status='pending',
                subtotal=0,
                tax_amount=0,
                total_amount=0,
                discount_amount=order_data.get('discount_amount', 0),
                shipping_address=order_data.get('shipping_address'),
                billing_address=order_data.get('billing_address'),
                delivery_instructions=order_data.get('delivery_instructions'),
                sales_rep_id=order_data.get('sales_rep_id'),
                notes=order_data.get('notes'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
            
            self.db.add(sales_order)
            self.db.flush()  # Get the order ID
            
            # Process order items
            order_items = order_data.get('items', [])
            total_amount = 0
            
            for item_data in order_items:
                # Validate inventory
                product_id = item_data['product_id']
                quantity = item_data['quantity']
                
                inventory = self.db.query(models.InventoryItem).filter(
                    and_(
                        models.InventoryItem.product_id == product_id,
                        models.InventoryItem.tenant_id == tenant_id
                    )
                ).first()
                
                if not inventory or inventory.available_quantity < quantity:
                    return {"error": f"Insufficient inventory for product {product_id}"}
                
                # Create order item
                order_item = models.SalesOrderItem(
                    order_id=sales_order.id,
                    product_id=product_id,
                    quantity=quantity,
                    unit_price=item_data['unit_price'],
                    discount_percentage=item_data.get('discount_percentage', 0),
                    total_price=quantity * item_data['unit_price'] * (1 - item_data.get('discount_percentage', 0) / 100),
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                
                self.db.add(order_item)
                total_amount += order_item.total_price
                
                # Reserve inventory
                inventory.reserved_quantity += quantity
            
            # Calculate totals
            tax_rate = order_data.get('tax_rate', 0)  # Tax rate as percentage
            tax_amount = total_amount * (tax_rate / 100)
            final_total = total_amount + tax_amount - sales_order.discount_amount
            
            sales_order.subtotal = total_amount
            sales_order.tax_amount = tax_amount
            sales_order.total_amount = final_total
            
            self.db.commit()
            
            # Create order confirmation
            await self._create_order_confirmation(sales_order.id, tenant_id)
            
            return {
                "success": True,
                "order_id": sales_order.id,
                "order_number": order_number,
                "total_amount": final_total,
                "status": "pending",
                "message": "Sales order created successfully"
            }
            
        except Exception as e:
            logger.error(f"Error creating sales order: {e}")
            self.db.rollback()
            return {"error": "Order creation failed"}

    async def update_order_status(self, order_id: int, status_data: Dict[str, Any], 
                               tenant_id: str = "default") -> Dict[str, Any]:
        """Update order status and process related actions"""
        try:
            order = self.db.query(models.SalesOrder).filter(
                and_(
                    models.SalesOrder.id == order_id,
                    models.SalesOrder.tenant_id == tenant_id
                )
            ).first()
            
            if not order:
                return {"error": "Order not found"}
            
            new_status = status_data.get('status')
            if new_status and new_status not in self.order_statuses:
                return {"error": f"Invalid status: {new_status}"}
            
            # Record status change
            status_history = models.OrderStatusHistory(
                order_id=order_id,
                old_status=order.status,
                new_status=new_status or order.status,
                changed_by=status_data.get('changed_by'),
                notes=status_data.get('notes'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(status_history)
            
            # Update order status
            if new_status:
                order.status = new_status
                
                # Process status-specific actions
                if new_status == 'confirmed':
                    await self._process_order_confirmation(order_id, tenant_id)
                elif new_status == 'processing':
                    await self._process_order_fulfillment(order_id, tenant_id)
                elif new_status == 'shipped':
                    await self._process_order_shipment(order_id, status_data, tenant_id)
                elif new_status == 'delivered':
                    await self._process_order_delivery(order_id, status_data, tenant_id)
                elif new_status == 'cancelled':
                    await self._process_order_cancellation(order_id, status_data, tenant_id)
            
            # Update payment status if provided
            if 'payment_status' in status_data:
                payment_status = status_data['payment_status']
                if payment_status in self.payment_statuses:
                    order.payment_status = payment_status
                    
                    if payment_status == 'paid':
                        await self._process_payment_confirmation(order_id, status_data, tenant_id)
            
            order.updated_at = datetime.utcnow()
            self.db.commit()
            
            return {
                "success": True,
                "order_id": order_id,
                "new_status": order.status,
                "payment_status": order.payment_status,
                "message": "Order status updated successfully"
            }
            
        except Exception as e:
            logger.error(f"Error updating order status: {e}")
            self.db.rollback()
            return {"error": "Status update failed"}

    async def create_customer(self, customer_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Create new customer record"""
        try:
            # Check for duplicate email
            existing_customer = self.db.query(models.Customer).filter(
                and_(
                    models.Customer.email == customer_data['email'],
                    models.Customer.tenant_id == tenant_id
                )
            ).first()
            
            if existing_customer:
                return {"error": "Customer with this email already exists"}
            
            # Create customer
            customer = models.Customer(
                customer_code=await self._generate_customer_code(tenant_id),
                company_name=customer_data.get('company_name'),
                first_name=customer_data.get('first_name'),
                last_name=customer_data.get('last_name'),
                email=customer_data['email'],
                phone=customer_data.get('phone'),
                mobile=customer_data.get('mobile'),
                billing_address=customer_data.get('billing_address'),
                shipping_address=customer_data.get('shipping_address'),
                customer_type=customer_data.get('customer_type', 'individual'),
                credit_limit=customer_data.get('credit_limit', 0),
                payment_terms=customer_data.get('payment_terms', 'net30'),
                tax_exempt=customer_data.get('tax_exempt', False),
                notes=customer_data.get('notes'),
                status='active',
                tenant_id=tenant_id,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
            
            self.db.add(customer)
            self.db.commit()
            
            return {
                "success": True,
                "customer_id": customer.id,
                "customer_code": customer.customer_code,
                "message": "Customer created successfully"
            }
            
        except Exception as e:
            logger.error(f"Error creating customer: {e}")
            self.db.rollback()
            return {"error": "Customer creation failed"}

    async def get_order_analytics(self, start_date: Optional[str] = None, end_date: Optional[str] = None,
                                customer_id: Optional[int] = None, tenant_id: str = "default") -> Dict[str, Any]:
        """Get comprehensive sales order analytics"""
        try:
            if not start_date:
                start_date = (datetime.utcnow() - timedelta(days=30)).strftime('%Y-%m-%d')
            if not end_date:
                end_date = datetime.utcnow().strftime('%Y-%m-%d')
            
            start_dt = datetime.strptime(start_date, '%Y-%m-%d')
            end_dt = datetime.strptime(end_date, '%Y-%m-%d')
            
            # Query orders
            query = self.db.query(models.SalesOrder).filter(
                and_(
                    models.SalesOrder.order_date >= start_dt.date(),
                    models.SalesOrder.order_date <= end_dt.date(),
                    models.SalesOrder.tenant_id == tenant_id
                )
            )
            
            if customer_id:
                query = query.filter(models.SalesOrder.customer_id == customer_id)
            
            orders = query.all()
            
            # Calculate analytics
            analytics = await self._calculate_order_analytics(orders, start_dt, end_dt)
            
            # Get top products
            top_products = await self._get_top_selling_products(orders, tenant_id)
            
            # Get customer analysis
            customer_analysis = await self._get_customer_analysis(orders, tenant_id)
            
            # Get revenue trends
            revenue_trends = await self._calculate_revenue_trends(orders, start_dt, end_dt)
            
            return {
                "period": {
                    "start_date": start_date,
                    "end_date": end_date,
                    "customer_id": customer_id
                },
                "summary": analytics,
                "top_products": top_products,
                "customer_analysis": customer_analysis,
                "revenue_trends": revenue_trends,
                "performance_metrics": await self._calculate_performance_metrics(orders)
            }
            
        except Exception as e:
            logger.error(f"Error getting order analytics: {e}")
            return {"error": "Analytics generation failed"}

    async def manage_inventory_allocation(self, order_id: int, tenant_id: str = "default") -> Dict[str, Any]:
        """Manage inventory allocation for orders"""
        try:
            order = self.db.query(models.SalesOrder).filter(
                and_(
                    models.SalesOrder.id == order_id,
                    models.SalesOrder.tenant_id == tenant_id
                )
            ).first()
            
            if not order:
                return {"error": "Order not found"}
            
            # Get order items
            order_items = self.db.query(models.SalesOrderItem).filter(
                models.SalesOrderItem.order_id == order_id
            ).all()
            
            allocation_results = []
            can_fulfill = True
            
            for item in order_items:
                inventory = self.db.query(models.InventoryItem).filter(
                    and_(
                        models.InventoryItem.product_id == item.product_id,
                        models.InventoryItem.tenant_id == tenant_id
                    )
                ).first()
                
                if not inventory:
                    allocation_results.append({
                        "product_id": item.product_id,
                        "status": "failed",
                        "reason": "Product not found in inventory"
                    })
                    can_fulfill = False
                    continue
                
                # Check availability
                available = inventory.available_quantity - inventory.reserved_quantity
                if available >= item.quantity:
                    # Allocate inventory
                    inventory.reserved_quantity += item.quantity
                    allocation_results.append({
                        "product_id": item.product_id,
                        "status": "allocated",
                        "quantity": item.quantity,
                        "remaining": available - item.quantity
                    })
                else:
                    allocation_results.append({
                        "product_id": item.product_id,
                        "status": "insufficient",
                        "required": item.quantity,
                        "available": available
                    })
                    can_fulfill = False
            
            self.db.commit()
            
            # Update order status if all items allocated
            if can_fulfill:
                order.status = 'confirmed'
                await self._create_allocation_record(order_id, allocation_results, tenant_id)
            
            return {
                "success": True,
                "order_id": order_id,
                "can_fulfill": can_fulfill,
                "allocation_results": allocation_results,
                "order_status": order.status
            }
            
        except Exception as e:
            logger.error(f"Error managing inventory allocation: {e}")
            self.db.rollback()
            return {"error": "Inventory allocation failed"}

    async def generate_invoice(self, order_id: int, invoice_data: Dict[str, Any], 
                             tenant_id: str = "default") -> Dict[str, Any]:
        """Generate invoice for sales order"""
        try:
            order = self.db.query(models.SalesOrder).filter(
                and_(
                    models.SalesOrder.id == order_id,
                    models.SalesOrder.tenant_id == tenant_id
                )
            ).first()
            
            if not order:
                return {"error": "Order not found"}
            
            # Generate invoice number
            invoice_number = await self._generate_invoice_number(tenant_id)
            
            # Create invoice
            invoice = models.Invoice(
                invoice_number=invoice_number,
                order_id=order_id,
                customer_id=order.customer_id,
                invoice_date=datetime.strptime(invoice_data['invoice_date'], '%Y-%m-%d').date() if isinstance(invoice_data.get('invoice_date'), str) else datetime.utcnow().date(),
                due_date=datetime.strptime(invoice_data['due_date'], '%Y-%m-%d').date() if isinstance(invoice_data.get('due_date'), str) else (datetime.utcnow() + timedelta(days=30)).date(),
                subtotal=order.subtotal,
                tax_amount=order.tax_amount,
                total_amount=order.total_amount,
                discount_amount=order.discount_amount,
                status='draft',
                payment_terms=invoice_data.get('payment_terms', 'net30'),
                notes=invoice_data.get('notes'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(invoice)
            self.db.commit()
            
            return {
                "success": True,
                "invoice_id": invoice.id,
                "invoice_number": invoice_number,
                "total_amount": invoice.total_amount,
                "due_date": invoice.due_date.strftime('%Y-%m-%d'),
                "message": "Invoice generated successfully"
            }
            
        except Exception as e:
            logger.error(f"Error generating invoice: {e}")
            self.db.rollback()
            return {"error": "Invoice generation failed"}

    # Helper methods
    async def _generate_order_number(self, tenant_id: str) -> str:
        """Generate unique order number"""
        try:
            count = self.db.query(models.SalesOrder).filter(models.SalesOrder.tenant_id == tenant_id).count()
            return f"SO-{tenant_id.upper()}-{datetime.utcnow().strftime('%Y%m%d')}-{count + 1:04d}"
        except:
            return f"SO-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"

    async def _generate_customer_code(self, tenant_id: str) -> str:
        """Generate unique customer code"""
        try:
            count = self.db.query(models.Customer).filter(models.Customer.tenant_id == tenant_id).count()
            return f"CUST-{tenant_id.upper()}-{count + 1:04d}"
        except:
            return f"CUST-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"

    async def _generate_invoice_number(self, tenant_id: str) -> str:
        """Generate unique invoice number"""
        try:
            count = self.db.query(models.Invoice).filter(models.Invoice.tenant_id == tenant_id).count()
            return f"INV-{tenant_id.upper()}-{datetime.utcnow().strftime('%Y%m%d')}-{count + 1:04d}"
        except:
            return f"INV-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"

    async def _create_order_confirmation(self, order_id: int, tenant_id: str):
        """Create order confirmation record"""
        try:
            confirmation = models.OrderConfirmation(
                order_id=order_id,
                confirmation_date=datetime.utcnow().date(),
                confirmation_number=await self._generate_confirmation_number(tenant_id),
                status='sent',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(confirmation)
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error creating order confirmation: {e}")

    async def _generate_confirmation_number(self, tenant_id: str) -> str:
        """Generate confirmation number"""
        return f"CONF-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"

    async def _process_order_confirmation(self, order_id: int, tenant_id: str):
        """Process order confirmation actions"""
        try:
            # Send confirmation email (would integrate with email service)
            # Update inventory reservations
            # Notify warehouse
            logger.info(f"Order {order_id} confirmed")
            
        except Exception as e:
            logger.error(f"Error processing order confirmation: {e}")

    async def _process_order_fulfillment(self, order_id: int, tenant_id: str):
        """Process order fulfillment"""
        try:
            # Create picking list
            # Reserve inventory
            # Schedule production if needed
            logger.info(f"Order {order_id} processing for fulfillment")
            
        except Exception as e:
            logger.error(f"Error processing order fulfillment: {e}")

    async def _process_order_shipment(self, order_id: int, status_data: Dict[str, Any], tenant_id: str):
        """Process order shipment"""
        try:
            # Create shipment record
            shipment = models.Shipment(
                order_id=order_id,
                tracking_number=status_data.get('tracking_number'),
                carrier=status_data.get('carrier'),
                shipped_date=datetime.strptime(status_data['shipped_date'], '%Y-%m-%d').date() if isinstance(status_data.get('shipped_date'), str) else datetime.utcnow().date(),
                estimated_delivery=datetime.strptime(status_data['estimated_delivery'], '%Y-%m-%d').date() if isinstance(status_data.get('estimated_delivery'), str) else (datetime.utcnow() + timedelta(days=3)).date(),
                status='shipped',
                notes=status_data.get('notes'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(shipment)
            
            # Update inventory (deduct from stock)
            await self._deduct_inventory_from_shipment(order_id, tenant_id)
            
            logger.info(f"Order {order_id} shipped")
            
        except Exception as e:
            logger.error(f"Error processing order shipment: {e}")

    async def _process_order_delivery(self, order_id: int, status_data: Dict[str, Any], tenant_id: str):
        """Process order delivery"""
        try:
            # Update shipment status
            # Record delivery confirmation
            # Trigger payment processing
            logger.info(f"Order {order_id} delivered")
            
        except Exception as e:
            logger.error(f"Error processing order delivery: {e}")

    async def _process_order_cancellation(self, order_id: int, status_data: Dict[str, Any], tenant_id: str):
        """Process order cancellation"""
        try:
            # Release inventory reservations
            # Process refunds if applicable
            # Update order status
            await self._release_inventory_reservations(order_id, tenant_id)
            
            logger.info(f"Order {order_id} cancelled")
            
        except Exception as e:
            logger.error(f"Error processing order cancellation: {e}")

    async def _process_payment_confirmation(self, order_id: int, status_data: Dict[str, Any], tenant_id: str):
        """Process payment confirmation"""
        try:
            # Create payment record
            payment = models.Payment(
                order_id=order_id,
                payment_amount=status_data.get('payment_amount'),
                payment_method=status_data.get('payment_method'),
                payment_date=datetime.strptime(status_data['payment_date'], '%Y-%m-%d').date() if isinstance(status_data.get('payment_date'), str) else datetime.utcnow().date(),
                transaction_id=status_data.get('transaction_id'),
                status='completed',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(payment)
            logger.info(f"Payment confirmed for order {order_id}")
            
        except Exception as e:
            logger.error(f"Error processing payment confirmation: {e}")

    async def _calculate_order_analytics(self, orders: List, start_dt: datetime, end_dt: datetime) -> Dict:
        """Calculate order analytics"""
        try:
            total_orders = len(orders)
            total_revenue = sum(order.total_amount for order in orders)
            average_order_value = total_revenue / total_orders if total_orders > 0 else 0
            
            # Status breakdown
            status_counts = {}
            for order in orders:
                if order.status not in status_counts:
                    status_counts[order.status] = 0
                status_counts[order.status] += 1
            
            # Payment status breakdown
            payment_counts = {}
            for order in orders:
                if order.payment_status not in payment_counts:
                    payment_counts[order.status] = 0
                payment_counts[order.payment_status] += 1
            
            return {
                "total_orders": total_orders,
                "total_revenue": total_revenue,
                "average_order_value": average_order_value,
                "status_breakdown": status_counts,
                "payment_breakdown": payment_counts
            }
            
        except Exception as e:
            logger.error(f"Error calculating order analytics: {e}")
            return {}

    async def _get_top_selling_products(self, orders: List, tenant_id: str) -> List[Dict]:
        """Get top selling products"""
        try:
            product_sales = defaultdict(lambda: {'quantity': 0, 'revenue': 0})
            
            for order in orders:
                order_items = self.db.query(models.SalesOrderItem).filter(
                    models.SalesOrderItem.order_id == order.id
                ).all()
                
                for item in order_items:
                    product_sales[item.product_id]['quantity'] += item.quantity
                    product_sales[item.product_id]['revenue'] += item.total_price
            
            # Sort by revenue
            top_products = sorted(product_sales.items(), key=lambda x: x[1]['revenue'], reverse=True)[:10]
            
            result = []
            for product_id, sales_data in top_products:
                product = self.db.query(models.Product).filter(models.Product.id == product_id).first()
                if product:
                    result.append({
                        "product_id": product_id,
                        "product_name": product.name,
                        "quantity_sold": sales_data['quantity'],
                        "revenue": sales_data['revenue']
                    })
            
            return result
            
        except Exception as e:
            logger.error(f"Error getting top selling products: {e}")
            return []

    async def _get_customer_analysis(self, orders: List, tenant_id: str) -> Dict:
        """Get customer analysis"""
        try:
            customer_orders = defaultdict(list)
            for order in orders:
                if order.customer_id:
                    customer_orders[order.customer_id].append(order)
            
            # Calculate customer metrics
            customer_metrics = {}
            for customer_id, customer_order_list in customer_orders.items():
                total_spent = sum(order.total_amount for order in customer_order_list)
                order_count = len(customer_order_list)
                avg_order_value = total_spent / order_count if order_count > 0 else 0
                
                customer_metrics[customer_id] = {
                    "order_count": order_count,
                    "total_spent": total_spent,
                    "average_order_value": avg_order_value
                }
            
            # Get top customers
            top_customers = sorted(customer_metrics.items(), key=lambda x: x[1]['total_spent'], reverse=True)[:10]
            
            return {
                "total_customers": len(customer_metrics),
                "top_customers": [
                    {
                        "customer_id": customer_id,
                        "order_count": metrics["order_count"],
                        "total_spent": metrics["total_spent"],
                        "average_order_value": metrics["average_order_value"]
                    }
                    for customer_id, metrics in top_customers
                ]
            }
            
        except Exception as e:
            logger.error(f"Error getting customer analysis: {e}")
            return {}

    async def _calculate_revenue_trends(self, orders: List, start_dt: datetime, end_dt: datetime) -> Dict:
        """Calculate revenue trends"""
        try:
            # Group by day
            daily_revenue = defaultdict(float)
            for order in orders:
                date_key = order.order_date.strftime('%Y-%m-%d')
                daily_revenue[date_key] += order.total_amount
            
            # Convert to sorted list
            sorted_dates = sorted(daily_revenue.keys())
            trend_data = [
                {
                    "date": date,
                    "revenue": daily_revenue[date]
                }
                for date in sorted_dates
            ]
            
            return {
                "daily_revenue": trend_data,
                "total_days": len(trend_data),
                "average_daily_revenue": sum(daily_revenue.values()) / len(daily_revenue) if daily_revenue else 0
            }
            
        except Exception as e:
            logger.error(f"Error calculating revenue trends: {e}")
            return {}

    async def _calculate_performance_metrics(self, orders: List) -> Dict:
        """Calculate performance metrics"""
        try:
            # Order fulfillment rate
            fulfilled_orders = len([o for o in orders if o.status in ['shipped', 'delivered']])
            fulfillment_rate = (fulfilled_orders / len(orders) * 100) if orders else 0
            
            # Payment collection rate
            paid_orders = len([o for o in orders if o.payment_status == 'paid'])
            payment_rate = (paid_orders / len(orders) * 100) if orders else 0
            
            # Average order processing time (mock calculation)
            processing_time = 2.5  # days
            
            return {
                "fulfillment_rate": round(fulfillment_rate, 2),
                "payment_collection_rate": round(payment_rate, 2),
                "average_processing_time_days": processing_time
            }
            
        except Exception as e:
            logger.error(f"Error calculating performance metrics: {e}")
            return {}

    async def _create_allocation_record(self, order_id: int, allocation_results: List[Dict], tenant_id: str):
        """Create inventory allocation record"""
        try:
            allocation = models.InventoryAllocation(
                order_id=order_id,
                allocation_details=json.dumps(allocation_results),
                allocation_date=datetime.utcnow().date(),
                status='completed',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(allocation)
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error creating allocation record: {e}")

    async def _deduct_inventory_from_shipment(self, order_id: int, tenant_id: str):
        """Deduct inventory from stock when order is shipped"""
        try:
            order_items = self.db.query(models.SalesOrderItem).filter(
                models.SalesOrderItem.order_id == order_id
            ).all()
            
            for item in order_items:
                inventory = self.db.query(models.InventoryItem).filter(
                    and_(
                        models.InventoryItem.product_id == item.product_id,
                        models.InventoryItem.tenant_id == tenant_id
                    )
                ).first()
                
                if inventory:
                    inventory.available_quantity -= item.quantity
                    inventory.reserved_quantity -= item.quantity
            
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error deducting inventory from shipment: {e}")

    async def _release_inventory_reservations(self, order_id: int, tenant_id: str):
        """Release inventory reservations when order is cancelled"""
        try:
            order_items = self.db.query(models.SalesOrderItem).filter(
                models.SalesOrderItem.order_id == order_id
            ).all()
            
            for item in order_items:
                inventory = self.db.query(models.InventoryItem).filter(
                    and_(
                        models.InventoryItem.product_id == item.product_id,
                        models.InventoryItem.tenant_id == tenant_id
                    )
                ).first()
                
                if inventory:
                    inventory.reserved_quantity -= item.quantity
            
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error releasing inventory reservations: {e}")
