# from flask import Flask, render_template, url_for, flash, redirect
# from forms import RegistrationForm
# from datetime import date
# import mysql.connector

# app = Flask(__name__)
# app.config['SECRET_KEY'] = 'xxxx'

# #Turn the results from the database into a dictionary
# def dict_factory(cursor, row):
#     d = {}
#     for idx, col in enumerate(cursor.description):
#         d[col[0]] = row[idx]
#     return d


# @app.route("/")
# @app.route("/home")
# def home():
    
#     conn = mysql.connector.connect(user='xxxx', password='xxxx', host='localhost', database="sabsdb")
#     cursor = conn.cursor()
#     cursor.execute("USE sabsdb")
    
#     #Display all items from the 'items' table
#     conn.row_factory = dict_factory
#     c = conn.cursor()
    
#     c.execute("SELECT * FROM items")
    
#     items = c.fetchall()

#     return render_template('home.html', items=items)


# @app.route("/register", methods=['GET', 'POST'])
# def register():
#     form = RegistrationForm()

#     if form.validate_on_submit():
#         conn = mysql.connector.connect(user='xxxx', password='xxxx', host='localhost', database="sabsdb")
#         cursor = conn.cursor()
#         cursor.execute("USE sabsdb")
#         c = conn.cursor()

#         points = 10
#         currentdate = str(date.today())
        
#         #Add the new blog into the 'blogs' table
#         query = "Insert into members(fname, lname, password, points, registeredDate, phoneNumber) VALUES (%s, %s, %s, %s, %s, %s)"
#         c.execute(query, (form.firstName.data, form.lastName.data, form.password.data, int(points), currentdate, form.phoneNumber.data)) #Execute the query
#         conn.commit() #Commit the changes

#         flash(f'Account created for {form.firstName.data} {form.lastName.data}!', 'success')
#         return redirect(url_for('home'))
#     return render_template('register.html', title='Register', form=form)

# if __name__ == '__main__':
#     app.run(debug=True)



from flask import Flask, render_template, url_for, flash, redirect, request, Response
from flask_login import LoginManager, UserMixin, login_required, login_user, logout_user, current_user
from forms import RegistrationForm, LoginForm
from datetime import date
import sqlite3

app = Flask(__name__)
app.config['SECRET_KEY'] = '5791628bb0b13ce0c676dfde280ba245'

login_manager = LoginManager(app)
login_manager.login_view = "login"

class Member(UserMixin):
    def __init__(self, id, fname, lname, email, password, points, registeredDate, phoneNumber):
        self.id = id
        self.fname = fname
        self.lname = lname
        self.email = email
        self.password = password
        self.points = points
        self.registeredDate = registeredDate
        self.phoneNumber = phoneNumber
        self.authenticated = False

    def is_active(self):
        return True

    def is_anonymous(self):
        return False

    def is_authenticated(self):
        return self.authenticated

    def get_id(self):
        return self.id
    

@login_manager.user_loader
def load_member(member_id):
    conn = sqlite3.connect('sabs.db')
    cursor = conn.cursor()
    cursor.execute("SELECT * from members WHERE id = (?)", str(member_id))
    row = cursor.fetchone()
    if row is None:
        return None
    else:
        return Member(int(row[0]), row[1], row[2], row[3], row[4], row[5], row[6], row[7])


# Create our tables and insert a few entries
def initialize_db():
    with open('database.sql', 'r') as sql_file:
        sql_script = sql_file.read()

    conn = sqlite3.connect('sabs.db')
    cursor = conn.cursor()
    cursor.executescript(sql_script)
    conn.commit()

#Turn the results from the database into a dictionary
def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d


initialize_db()

@app.route("/")
@app.route("/home")
def home():
    
    conn = sqlite3.connect('sabs.db')
    
    #Display all items from the 'items' table
    conn.row_factory = dict_factory
    c = conn.cursor()
    
    c.execute("SELECT * FROM items")
    
    items = c.fetchall()

    return render_template('home.html', items=items)


@app.route("/register", methods=['GET', 'POST'])
def register():

    registration_form = RegistrationForm()

    if registration_form.validate_on_submit():
        conn = sqlite3.connect('sabs.db')
        c = conn.cursor()

        points = 10
        currentdate = str(date.today())
        
        #Add the new blog into the 'members' table
        # Note: first value is NULL because sqlite automatically takes care of id
        query = "INSERT into members VALUES (NULL, ?, ?, ?, ?, ?, ?, ?)"
        c.execute(query, (registration_form.firstName.data, registration_form.lastName.data, registration_form.email.data, registration_form.password.data, points, currentdate, registration_form.phoneNumber.data)) #Execute the query
        conn.commit() #Commit the changes

        flash(f'Account created for {registration_form.firstName.data} {registration_form.lastName.data}!', 'success')
        return redirect(url_for('home'))

    return render_template('register.html', title='Register', registration_form=registration_form)

@app.route("/login", methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('profile'))
    
    form = LoginForm()
    if form.validate_on_submit():
        conn = sqlite3.connect('sabs.db')
        c = conn.cursor()
        c.execute("SELECT * FROM members WHERE email = (?) AND password = (?)", [form.email.data, form.password.data])
        row = c.fetchone()
        if row is not None:
            row = list(row)
            if row[3] == form.email.data and row[4] == form.password.data:
                valid_member = load_member(row[0])
                login_user(valid_member, remember=form.remember.data)
                flash(f'Login successful for {row[1]} {row[2]}!', 'success')
                return redirect(url_for('home'))
            else:
                flash(f'Incorrect email or password', 'error')

    return render_template('login.html', title='Login', form=form)



@app.route("/profile", methods=['GET', 'POST'])
@login_required
def profile():
    return render_template('profile.html', title='Profile')

@app.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect(url_for('home'))


if __name__ == '__main__':
    app.run(debug=True)

