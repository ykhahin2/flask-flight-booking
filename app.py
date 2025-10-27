from flask import Flask, render_template, request, redirect, session, url_for
from flask_mysqldb import MySQL
import MySQLdb.cursors
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import re

app = Flask(__name__)
app.secret_key = '1APm2kmySPnjRjtd=gnm7LjarbKdb.W9'

# Database config
# enter login info
app.config['MYSQL_HOST'] = ''
app.config['MYSQL_USER'] = ''
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = ''

mysql = MySQL(app)

def validate_flight_input(form):
    try:
        if not form.get('origin') or not form.get('destination'):
            return False
        datetime.strptime(form['departure'], '%H:%M')
        datetime.strptime(form['arrival'], '%H:%M')
        float(form['price'])
        int(form['seats'])
        return True
    except:
        return False

@app.route('/')
def home():
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("SELECT * FROM air_journeys")
    all_flights = cur.fetchall()
    cur.close()
    return render_template('book.html', air_journeys=all_flights)

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        username = request.form.get('username', '').strip()
        email = request.form.get('email', '').strip()
        password = request.form.get('password')

        if not all([name, username, email, password]):
            return "All fields are required", 400

        if not re.match(r'^[a-zA-Z0-9_]{3,20}$', username):
            return "Invalid username format", 400

        cur = mysql.connection.cursor()
        try:
            cur.execute('SELECT user_id FROM users WHERE username = %s', (username,))
            if cur.fetchone():
                return "Username already exists", 400

            hashed = generate_password_hash(password)
            cur.execute('''INSERT INTO users (name, username, email, password, role)
                        VALUES (%s, %s, %s, %s, "customer")''',
                        (name, username, email, hashed))
            mysql.connection.commit()
            return redirect('/login')
        except Exception as err:
            mysql.connection.rollback()
            return f"Registration error: {err}", 400
        finally:
            cur.close()
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        uname = request.form['username'].strip()
        pw = request.form['password']

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute('SELECT * FROM users WHERE username = %s', (uname,))
        user = cur.fetchone()
        cur.close()

        if user and check_password_hash(user['password'], pw):
            session['user_id'] = user['user_id']
            session['username'] = user['username']
            session['role'] = user.get('role', 'customer')
            return redirect('/')
        
        return "Invalid username or password", 401
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect('/')

@app.route('/book', methods=['POST'])
def book():
    if 'user_id' not in session:
        return redirect('/login')

    try:
        journey_id = int(request.form['journey_id'])
        seat_type = request.form.get('seat_type')
        seats = int(request.form['seats'])
        journey_date = datetime.strptime(request.form['journey_date'], '%Y-%m-%d').date()

        if seat_type not in ['business', 'economy']:
            return "Seat type is invalid", 400

        if journey_date < datetime.now().date():
            return "Date can't be in the past", 400

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute('SELECT * FROM air_journeys WHERE journey_id = %s', (journey_id,))
        journey = cur.fetchone()

        price = float(journey['price']) * (2 if seat_type == 'business' else 1)
        total = price * seats

        cur.execute(f'''UPDATE air_journeys SET {seat_type}_seats = {seat_type}_seats - %s 
                     WHERE journey_id = %s''', (seats, journey_id))
        cur.execute('''INSERT INTO bookings (user_id, journey_id, journey_date, seats, seat_type, total_price)
                     VALUES (%s, %s, %s, %s, %s, %s)''',
                     (session['user_id'], journey_id, journey_date, seats, seat_type, total))

        mysql.connection.commit()
        return redirect('/bookings')

    except Exception as e:
        mysql.connection.rollback()
        return f"Booking error: {e}", 400
    finally:
        cur.close()

@app.route('/bookings')
def bookings():
    if 'user_id' not in session:
        return redirect('/login')

    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    if session.get('role') == 'admin':
        cur.execute('''SELECT b.*, aj.origin, aj.destination, u.username
                     FROM bookings b
                     JOIN air_journeys aj ON b.journey_id = aj.journey_id
                     JOIN users u ON b.user_id = u.user_id
                     ORDER BY b.booking_id DESC''')
    else:
        cur.execute('''SELECT b.*, aj.origin, aj.destination
                     FROM bookings b
                     JOIN air_journeys aj ON b.journey_id = aj.journey_id
                     WHERE b.user_id = %s
                     ORDER BY b.booking_id DESC''', (session['user_id'],))

    result = cur.fetchall()
    today = datetime.now().date()
    for r in result:
        r['days_remaining'] = (r['journey_date'] - today).days

    cur.close()
    return render_template('bookings.html', bookings=result)

@app.route('/cancel/<int:booking_id>')
def cancel_booking(booking_id):
    try:
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute('''SELECT journey_date, total_price, seats, journey_id, seat_type
                     FROM bookings WHERE booking_id = %s AND status != 'cancelled' ''',
                     (booking_id,))
        row = cur.fetchone()

        if not row:
            return "No such active booking", 404

        days_left = (row['journey_date'] - datetime.now().date()).days
        refund, charge = 0, 0

        if days_left > 60:
            refund = float(row['total_price'])
        elif days_left >= 30:
            charge = float(row['total_price']) * 0.4
            refund = float(row['total_price']) - charge
        else:
            charge = float(row['total_price'])

        cur.execute('''UPDATE bookings SET status = 'cancelled', refund_amount = %s,
                     cancellation_charge = %s WHERE booking_id = %s''',
                     (refund, charge, booking_id))

        cur.execute(f'''UPDATE air_journeys SET {row['seat_type']}_seats = {row['seat_type']}_seats + %s
                     WHERE journey_id = %s''', (row['seats'], row['journey_id']))

        mysql.connection.commit()
        return redirect('/bookings')
    except Exception as e:
        mysql.connection.rollback()
        return f"Cancellation failed: {e}", 500
    finally:
        cur.close()

@app.route('/admin')
def admin_dashboard():
    if session.get('role') != 'admin':
        return redirect('/login')

    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute('''SELECT aj.journey_id, CONCAT(aj.origin, " → ", aj.destination) AS route,
                 COUNT(b.booking_id) AS bookings_count,
                 COALESCE(SUM(CASE WHEN b.status = 'active' THEN b.total_price ELSE 0 END), 0) AS total_revenue
                 FROM air_journeys aj
                 LEFT JOIN bookings b ON aj.journey_id = b.journey_id
                 GROUP BY aj.journey_id''')
    flights = cur.fetchall()

    cur.execute('''SELECT seat_type, COUNT(*) AS total_bookings,
                 COALESCE(SUM(CASE WHEN status = 'active' THEN total_price ELSE 0 END), 0) AS total_revenue
                 FROM bookings GROUP BY seat_type''')
    seats = cur.fetchall()

    cur.execute('''SELECT b.booking_id, u.username, CONCAT(aj.origin, " → ", aj.destination) AS route,
                 b.journey_date, b.total_price, b.status
                 FROM bookings b
                 JOIN users u ON b.user_id = u.user_id
                 JOIN air_journeys aj ON b.journey_id = aj.journey_id
                 ORDER BY b.booking_id DESC LIMIT 10''')
    recent = cur.fetchall()

    cur.close()
    return render_template('admin.html', sales_report=flights, seat_stats=seats, recent_bookings=recent)

@app.route('/admin/add-flight', methods=['GET', 'POST'])
def add_flight():
    if session.get('role') != 'admin':
        return redirect('/login')

    if request.method == 'POST':
        if not validate_flight_input(request.form):
            return "Invalid input", 400

        try:
            seats = int(request.form['seats'])
            cur = mysql.connection.cursor()
            cur.execute('''INSERT INTO air_journeys (origin, destination, departure_time, arrival_time, price,
                         available_seats, business_seats, economy_seats)
                         VALUES (%s, %s, %s, %s, %s, %s, %s, %s)''',
                         (request.form['origin'].strip().title(),
                          request.form['destination'].strip().title(),
                          request.form['departure'],
                          request.form['arrival'],
                          float(request.form['price']),
                          seats, int(seats * 0.2), int(seats * 0.8)))
            mysql.connection.commit()
            return redirect('/admin')
        except Exception as e:
            mysql.connection.rollback()
            return f"Flight addition error: {e}", 400
        finally:
            cur.close()
    
    return render_template('add_flight.html')

@app.route('/admin/delete-flight/<int:journey_id>', methods=['POST'])
def delete_flight(journey_id):
    if session.get('role') != 'admin':
        return redirect('/login')
    try:
        cur = mysql.connection.cursor()
        cur.execute('DELETE FROM air_journeys WHERE journey_id = %s', (journey_id,))
        mysql.connection.commit()
        return redirect('/admin')
    except Exception as e:
        mysql.connection.rollback()
        return f"Delete error: {e}", 400
    finally:
        cur.close()

if __name__ == '__main__':
    app.run(debug=True)