from flask import Flask, render_template, url_for, flash, redirect, request, Response
from flask_login import LoginManager, UserMixin, login_required, login_user, logout_user, current_user
from forms import RegistrationForm, LoginForm, TimeSelectForm, EditInformationForm, changePasswordForm, AddForm
from classes.member import Member
import datetime
import time
import sqlite3
from passlib.hash import pbkdf2_sha256

app = Flask(__name__)
app.config['SECRET_KEY'] = '5791628bb0b13ce0c676dfde280ba245'

login_manager = LoginManager(app)
login_manager.login_view = "login"
login_manager.login_message = f"Please login to access this page"
login_manager.login_message_category = "info"

@login_manager.user_loader
def load_member(member_id):
    conn = sqlite3.connect('sabs.db')
    cursor = conn.cursor()
    cursor.execute("SELECT * from member WHERE memberID = (?)", str(member_id))
    row = cursor.fetchone()
    if row is None:
        return None
    else:        
        return Member(int(row[0]), row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12])


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

def db_connection():
    conn = sqlite3.connect('sabs.db')
    conn.row_factory = dict_factory

    return conn

def item_name_path(list_of_something):
    # Create the path to display images
    itemNamesList = []
    for x in list_of_something:
        name = "../static/images/"
        name = name + str(x["itemName"]).replace(" ", "")
        name = name + ".png"
        itemNamesList.append(name)

    return itemNamesList

def check_unique_email(user_email):
    conn = db_connection()
    c = conn.cursor()

    query = "SELECT email FROM member WHERE email = (?)"
    c.execute(query, [user_email])

    row = c.fetchone()
    if row is None:
        return True
    else:
        return False

# Run initialize the db before the app starts running
initialize_db()

@app.route("/")
@app.route("/home")
def home():
    query = "SELECT * FROM item"
    if ('brand' in request.args and  request.args.get('brand', type=str) != ""):
        query = "SELECT * FROM item WHERE brand=\"" + request.args.get('brand', type=str) + '\"'

    conn = db_connection()
    c = conn.cursor()
    c.execute(query)

    items = c.fetchall()

    # Create the path to display item images
    itemNamesList = []
    for x in items:
        name = "../static/images/"
        name = name + str(x["itemName"]).replace(" ", "")
        name = name + ".png"
        x['image'] = name

    return render_template('home.html', items=items, item_names_list=itemNamesList, length=len(items))


@app.route("/register", methods=['GET'])
def register():

    registration_form = RegistrationForm()

    if registration_form.validate_on_submit():
        if check_unique_email(registration_form.email.data) == False:
            flash(f'An account with this email already exists!', 'danger')
            return render_template('register.html', title='Register', registration_form=registration_form)
        conn = db_connection()
        c = conn.cursor()

        points = 10
        currentdate = str(datetime.date.today())
        companyName = 'SABS General Store'

        # Create the query
        # Note: first value is NULL because sqlite automatically takes care of id
        query = "INSERT into member VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"

        hashed_password = pbkdf2_sha256.hash(str(registration_form.password.data))

        # Execute the query
        c.execute(query, (
            registration_form.firstName.data, 
            registration_form.lastName.data, 
            registration_form.email.data, 
            hashed_password, 
            points, currentdate, companyName, 
            registration_form.street_address.data,
            registration_form.city.data,
            registration_form.zip_code.data,
            registration_form.province.data, 
            registration_form.birthdate.data
            ))

        # Commit the changes
        conn.commit()

        new_member = load_member(c.lastrowid)
        login_user(new_member)

        flash(f'Account created for {registration_form.firstName.data} {registration_form.lastName.data}!', 'success')
        return redirect(url_for('profile'))

    return render_template('register.html', title='Register', registration_form=registration_form)

@app.route("/login", methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('profile'))

    form = LoginForm()
    if form.validate_on_submit():
        conn = db_connection()
        c = conn.cursor()
        query = "SELECT * FROM member WHERE email = (?)"
        c.execute(query, [str(form.email.data)])
        row = c.fetchone()

        if row is not None:
            if row["email"] == form.email.data and pbkdf2_sha256.verify(form.password.data, row["member_password"]):
                valid_member = load_member(row["memberID"])
                login_user(valid_member, remember=form.remember.data)
                flash(f'{row["fname"]} {row["lname"]} is now logged in!', 'success')
                return redirect(url_for('home'))
            else:
                flash(f'Incorrect email or password', '')
        else:
            flash(f"Uh oh, looks like you are not a member!", "danger")

    return render_template('login.html', title='Login', form=form)



@app.route("/profile/pastPurchases", methods=['GET', 'POST'])
@login_required
def pastPurchases():

    conn = db_connection()
    c = conn.cursor()
    items_query = ""

    form = TimeSelectForm()

    if form.validate_on_submit:
        current_time = int(time.time())

        if form.timeInput.data == "All":
            items_query = "SELECT * FROM buys WHERE memberID = (?)"
            c.execute(items_query, str(current_user.id))
        else:
            if form.timeInput.data == "SevenDays":
                time_period = current_time - 604800

            elif form.timeInput.data == "OneMonth":
                time_period = current_time - 2629743

            items_query = "SELECT * FROM buys WHERE memberID = (?) AND date_of_purchase <= (?) and date_of_purchase >= (?)"
            c.execute(items_query, (str(current_user.id), current_time, time_period))

        purchases = c.fetchall()
        itemImgPath = item_name_path(purchases)

    for purchase in purchases:
        purchase['date_of_purchase'] = datetime.datetime.utcfromtimestamp(purchase['date_of_purchase']).strftime('%Y-%m-%d %H:%M:%S')

    return render_template('pastPurchases.html', purchases=purchases, itemImgPath=itemImgPath, length=len(purchases),  form=form, title='Past Purchases')


@app.route("/profile", methods=['GET', 'POST'])
@login_required
def profile():
    return render_template('profile.html', title='Profile')

@app.route("/logout")
@login_required
def logout():
    name = current_user.fname
    logout_user()
    flash(f'{name} has been logged out!', 'success')
    return redirect(url_for('home'))

@app.route("/profile/checkout=success/customerReceipt", methods=['GET'])
@login_required
def customer_receipt():
    return render_template('customerReceipt.html', title='Customer Receipt')


@app.route("/profile/editInfo", methods=['GET', 'POST'])
@login_required
def editInfo(): 

    # Get the user informaiton first to diplay in the form
    conn = db_connection()
    c = conn.cursor()

    get_info_query = "SELECT * FROM member WHERE memberID = (?)"
    c.execute(get_info_query, str(current_user.id))
    member = c.fetchone()

    form = EditInformationForm()

    if request.method == 'GET':
        form.firstName.data = member["fname"]
        form.lastName.data = member["lname"]
        form.email.data = member["email"]
        form.street_address.data = member["address_street"]
        form.city.data = member["address_city"]
        form.zip_code.data = member["address_zip"]
        form.province.data = member["address_province"]
        form.birthdate.data = member["birthdate"]

        c.close()
        conn.close()

    if form.validate_on_submit():

        conn = db_connection()
        c = conn.cursor()

        # Create the query
        query = "UPDATE member SET fname = (?), lname = (?), email = (?), birthdate = (?), address_street = (?), address_city = (?), address_zip = (?), address_province = (?) WHERE memberID = (?)"

        # Execute the query
        c.execute(query, (
            form.firstName.data, 
            form.lastName.data, 
            form.email.data, 
            form.birthdate.data, 
            form.street_address.data,
            form.city.data,
            form.zip_code.data,
            form.province.data,
            str(current_user.id)
            )) 

        # Commit the changes
        conn.commit()
        flash(f'Your information has been updated {form.firstName.data}!', 'success')
        return(redirect(url_for('profile')))

    return render_template('editInfo.html', form=form, title='Edit your information')

@app.route("/profile/editInfo/changePassword", methods=['GET', 'POST'])
@login_required
def changePassword():

    change_password_form = changePasswordForm()

    if change_password_form.validate_on_submit():

        conn = db_connection()
        c = conn.cursor()

        query = "SELECT member_password FROM member WHERE memberID = (?)"
        c.execute(query, str(current_user.id))
        old_pass = c.fetchone()
        print(old_pass)
        
        if pbkdf2_sha256.verify(change_password_form.old_password.data, old_pass["member_password"]):
        
            query = "UPDATE member SET member_password = (?) WHERE memberID = (?)"
            
            hashed_password = pbkdf2_sha256.hash(change_password_form.new_password.data)
            
            c.execute(query, (hashed_password, str(current_user.id)))
            conn.commit()

            flash(f"Your password has been updated", "success")
            return redirect(url_for('profile'))

        else:
            flash(f"Unable to make changes: Your old password is incorrect", "danger")

    return render_template('changePassword.html', change_password_form=change_password_form, title='Change Password') 

@app.route('/searchResults')
def searchResults():

    user_query = "%"
    temp = request.args.get("q")
    user_query = user_query + str(temp) + "%"
    conn = db_connection()
    c = conn.cursor()

    query = "SELECT * FROM item WHERE itemName LIKE (?)"
    c.execute(query, [user_query])

    matching_items = c.fetchall()
    matching_items_images = item_name_path(matching_items)

    return render_template('searchResults.html', matching_items=matching_items, matching_items_images=matching_items_images, length=len(matching_items), search_query=str(temp), title='Search results')

@app.route("/ProductDescription/<itemID>")
def show(itemID):
    conn = db_connection()
    c = conn.cursor()
    temp = str(itemID)
    query = "SELECT * FROM item WHERE itemID = (?)"
    c.execute(query, (temp,))
    item = c.fetchone()
    return render_template('ProductDescription.html', item =item, title = 'Description' )



@app.route("/cart", methods=['GET'])
@login_required
def cart():
    conn = db_connection()
    c = conn.cursor()
    items_query = "SELECT * FROM cart WHERE cartID = (?)"
    c.execute(items_query, str(current_user.id))
    items = c.fetchall()

    sum = 0
    for x in items:
        sum = sum + x['objectPrice'] 
 
    return render_template('cart.html', items = items, length = len(items), total = sum, title = 'cart')


@app.route('/cart/<int:itemID>')
@login_required
def add_to_cart(itemID):
    conn = db_connection()
    c = conn.cursor()
    temp = str(itemID)
    query = "SELECT * FROM item WHERE itemID = (?)"
    c.execute(query, (temp,))
    item = c.fetchone()

    query2 = "INSERT into cart VALUES (?, ?, ?, ?)"
    c.execute(query2,(current_user.id,item['itemID'], item['itemName'], item['price']))
    conn.commit()
    return redirect(url_for('cart'))
    


@app.route("/add", methods=['GET', 'POST'])
def add():
    form = AddForm()

    if form.validate_on_submit():
        conn = sqlite3.connect('sabs.db')
        c = conn.cursor()

        try:
            query = "Insert into items(itemid, itemName, brand, size, price, stock) VALUES (?, ?, ?, ?, ?, ?)"
            c.execute(query, (form.itemid.data, form.itemName.data, form.brand.data, form.size.data, form.price.data, form.stock.data)) #Execute the query
            conn.commit() #Commit the changes
            flash(f'{form.itemName.data} added to database with the ID of {form.itemid.data}!', 'success')
            return redirect(url_for('home'))
        except:
            flash(f'{form.itemName.data} failed to be added to the DB!', 'danger')

    return render_template('add.html', title='Add', form=form)

if __name__ == '__main__':
    app.run(debug=True)

