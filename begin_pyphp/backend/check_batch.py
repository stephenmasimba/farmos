from sqlalchemy import create_engine, text

engine = create_engine('mysql+pymysql://root:@localhost/begin_masimba_farm')
with engine.connect() as conn:
    # Look for our specific batches
    result = conn.execute(text('SELECT batch_code, type, name, quantity, start_date, breed, location FROM livestock_batches WHERE batch_code LIKE "Broiler%" ORDER BY id DESC LIMIT 5'))
    batches = [row for row in result]
    print('Recent Broiler Batches:')
    for row in batches:
        print(f'  {row[0]} - {row[1]} - {row[2]} - Qty: {row[3]} - Date: {row[4]} - Breed: {row[5]} - Location: {row[6]}')
