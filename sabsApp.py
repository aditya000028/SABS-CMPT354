from flask import Flask, render_template, url_for, flash, redirect
from forms import RegistrationForm
from datetime import date
import mysql.connector

app = Flask(__name__)
app.config['SECRET_KEY'] = 'xxxx'

#Turn the results from the database into a dictionary
def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d


@app.route("/")
@app.route("/home")
def home():
    
    conn = mysql.connector.connect(user='xxxx', password='xxxx', host='localhost', database="sabsdb")
    cursor = conn.cursor()
    cursor.execute("USE sabsdb")
    
    #Display all items from the 'items' table
    conn.row_factory = dict_factory
    c = conn.cursor()
    
    c.execute("SELECT * FROM items")
    
    items = c.fetchall()

    return render_template('home.html', items=items)


@app.route("/register", methods=['GET', 'POST'])
def register():
    form = RegistrationForm()

    if form.validate_on_submit():
        conn = mysql.connector.connect(user='xxxx', password='xxxx', host='localhost', database="sabsdb")
        cursor = conn.cursor()
        cursor.execute("USE sabsdb")
        c = conn.cursor()

        points = 10
        currentdate = str(date.today())
        
        #Add the new blog into the 'blogs' table
        query = "Insert into members(fname, lname, password, points, registeredDate, phoneNumber) VALUES (%s, %s, %s, %s, %s, %s)"
        c.execute(query, (form.firstName.data, form.lastName.data, form.password.data, int(points), currentdate, form.phoneNumber.data)) #Execute the query
        conn.commit() #Commit the changes

        flash(f'Account created for {form.firstName.data} {form.lastName.data}!', 'success')
        return redirect(url_for('home'))
    return render_template('register.html', title='Register', form=form)

if __name__ == '__main__':
    app.run(debug=True)

