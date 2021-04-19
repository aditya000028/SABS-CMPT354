from flask import Flask, render_template, url_for, flash, redirect, request, Response
from flask_login import LoginManager, UserMixin, login_required, login_user, logout_user, current_user
from forms import RegistrationForm, LoginForm, TimeSelectForm, EditInformationForm, ChangePasswordForm, AddForm, CheckoutForm, AdminDeleteForm
from utilityFunctions import initialize_db, dict_factory, db_connection, item_name_path, check_unique_email, calculate_new_price, new_stock
from classes.member import Member
import datetime
import time
import sqlite3
from passlib.hash import pbkdf2_sha256

# Initialize the db before the app starts running
initialize_db()

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


@app.route("/register", methods=['GET', 'POST'])
def register():

    registration_form = RegistrationForm()

    if registration_form.validate_on_submit():
        if check_unique_email(registration_form.email.data) == False:
            flash(f'An account with this email already exists!', 'danger')
            return render_template('register.html', title='Register', registration_form=registration_form)
        conn = db_connection()
        c = conn.cursor()

        # Start the member off with a 1% discount
        points = 1
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

        # Load the newly created member and redirect them to their profile
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
            flash(f"Uh oh, looks like you are not a member! You must be a member to login", "danger")

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

# Since flask does not support different types of user logins, if a user is signed up
# using the sabs email, they will be able to delete forms
# this is to satisfy the assignment requirement 'delete operation with cascade'
@app.route("/profile/adminDeleteItems", methods=['GET', 'POST'])
@login_required
def adminDeleteItems():

    if current_user.email == "SabsGeneralStore@gmail.com":
        form = AdminDeleteForm()
        if form.is_submitted():
            conn = db_connection()
            c = conn.cursor()
            query = "DELETE FROM item WHERE itemName = (?)"
            c.execute(query, [form.item_options.data])
            conn.commit()
            flash(f"The item '{form.item_options.data}' has been deleted", "info")
    else:
        flash(f"You do not have permission to access this page", "info")
        return redirect(url_for('profile'))

    return render_template('adminDeleteItems.html', form=form, title='Delete Items')

@app.route("/logout")
@login_required
def logout():
    name = current_user.fname
    logout_user()
    flash(f'{name} has been logged out!', 'success')
    return redirect(url_for('home'))

@app.route("/profile/checkout", methods=['GET', 'POST'])
@login_required
def checkout():

    checkout_form = CheckoutForm()

    query = "SELECT * FROM cart, item WHERE objectID = itemID AND cartID = (?)"
    
    conn = db_connection()
    c = conn.cursor()
    c.execute(query, str(current_user.id))
    
    cart_info = c.fetchall()

    if len(cart_info) == 0:
        flash(f"You must have an item in your cart to go to checkout", "info")
        return redirect(url_for('home'))
    new_prices = []

    for item in cart_info:
        new_prices.append(calculate_new_price(current_user.points, float(item["price"]), item["discountPercent"]))

    item_pictures_paths = item_name_path(cart_info)

    if checkout_form.validate_on_submit():
        buys_table_updated = []
        for item in cart_info:
            receipt = "You have bought " + item["itemName"]

            buys_table_updated.append([item["objectID"], 
                                    item["itemName"],
                                    item["brand"],
                                    item["size"], 
                                    item["price"], 
                                    item["discountPercent"], 
                                    str(current_user.id),
                                    receipt,
                                    str(datetime.date.today()),
                                    item["cartID"]
                                    ])
        
        # Update the member points
        points_query = "UPDATE member SET points = (?) WHERE memberID = (?)"
        if current_user.points == 10:
            current_user.points = 0
        else:
            current_user.points = current_user.points + 1
            
        c.execute(points_query, (current_user.points, str(current_user.id)))
        conn.commit()

        # Update the stock of item purchased
        new_stock_items = new_stock(cart_info)
        stock_query = "UPDATE item SET stock = (?) WHERE itemID = (?)"
        c.executemany(stock_query, new_stock_items)
        conn.commit()

        # Update the cart of member
        delete_cart_items_query = "DELETE FROM cart WHERE cartID = (?)"
        c.execute(delete_cart_items_query, str(current_user.id))
        conn.commit()

        # Update the 'buys' table
        buys_table_update_query = "INSERT INTO buys VALUES (?,?,?,?,?,?,?,?,?,?)"
        c.executemany(buys_table_update_query, buys_table_updated)
        conn.commit()

        flash(f"Items purchased! Thank you for shopping with us", "success")

        return redirect(url_for('home'))

    return render_template('checkout.html', new_prices=new_prices, checkout_form=checkout_form, item_pictures_paths=item_pictures_paths, cart_info=cart_info, length=len(cart_info), title='Checkout')

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

    change_password_form = ChangePasswordForm()

    if change_password_form.validate_on_submit():

        conn = db_connection()
        c = conn.cursor()

        query = "SELECT member_password FROM member WHERE memberID = (?)"
        c.execute(query, str(current_user.id))
        old_pass = c.fetchone()
        
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

    query = "SELECT COUNT(*) as 'num' FROM item WHERE itemName LIKE (?)"
    c.execute(query, [user_query])
    num_results = int((c.fetchone())["num"])

    matching_items_images = item_name_path(matching_items)

    return render_template('searchResults.html', matching_items=matching_items, matching_items_images=matching_items_images, num_results=num_results, search_query=str(temp), title='Search results')

@app.route("/ProductDescription/<itemID>")
def show(itemID):
    conn = db_connection()
    c = conn.cursor()
    temp = str(itemID)
    query = "SELECT * FROM item WHERE itemID = (?)"
    c.execute(query, (temp,))
    item = c.fetchone()

    query = "SELECT rating, content FROM review WHERE itemID = (?)"
    c.execute(query, (temp,))
    reviews = c.fetchall()

    name = "../static/images/"
    name = name + str(item["itemName"]).replace(" ", "")
    name = name + ".png"
    item['image'] = name

    return render_template('ProductDescription.html', item =item, title = 'Description', itemID = itemID, reviews = reviews, reviewsLen = len(reviews))

@app.route('/submit/<itemID>', methods=['POST'])
@login_required
def submit(itemID):
    conn = db_connection()
    c = conn.cursor()
    temp = str(itemID)
    query = "SELECT COUNT(reviewNumber) FROM review"
    c.execute(query, ())
    numberOfReviews = c.fetchone()
    numberOfReviews = numberOfReviews['COUNT(reviewNumber)']

    query = "SELECT * FROM item WHERE itemID = (?)"
    c.execute(query, (temp,))
    item = c.fetchone()

    review_query = "SELECT rating, content FROM review WHERE itemID = (?)"
    c.execute(review_query, (temp,))
    reviews = c.fetchall()

    tempMember = current_user.id
    query = "SELECT memberID FROM review WHERE memberID = (?) AND itemID = (?)"
    c.execute(query, (tempMember, temp,))
    memberIDArr = c.fetchall()
    
    if (len(memberIDArr) == 0):
        query = "INSERT into review VALUES(?, ?, ?, ?, ?)"
        c.execute(query, (numberOfReviews + 1, itemID, current_user.id, request.form['rating'], request.form['content']))
        conn.commit()

    review_query = "SELECT rating, content FROM review WHERE itemID = (?)"
    c.execute(review_query, (temp,))
    reviews = c.fetchall()

    name = "../static/images/"
    name = name + str(item["itemName"]).replace(" ", "")
    name = name + ".png"
    item['image'] = name

    return render_template('ProductDescription.html', item =item, title = 'Description', itemID = itemID, reviews = reviews, reviewsLen = len(reviews))

@app.route("/cart", methods=['GET'])
@login_required
def cart():
     conn = db_connection()
     c = conn.cursor()
     items_query = "SELECT * FROM cart,item WHERE cartID = (?) AND item.itemID IN( SELECT itemID FROM item WHERE itemID = objectID)"
     c.execute(items_query, str(current_user.id))
     items = c.fetchall()

     matching_items_images = item_name_path(items)
     
     sum = 0
     for x in items:
         sum = sum + x['price'] 
 
     return render_template('cart.html', items = items, matching_items_images = matching_items_images, length = len(items), total = sum, title = 'cart')
     


@app.route('/cart/<int:itemID>')
@login_required
def add_to_cart(itemID):
     conn = db_connection()
     c = conn.cursor()
     temp = str(itemID)
     query = "SELECT * FROM item WHERE itemID = (?)"
     c.execute(query, (temp,))
     item = c.fetchone()

     query2 = "INSERT into cart VALUES (?, ?)"
     c.execute(query2,(current_user.id,item['itemID']))
     conn.commit()
     return redirect(url_for('cart'))

@app.route('/home/<int:itemID>')
@login_required
def remove_from_cart(itemID):
     conn = db_connection()
     c = conn.cursor()
     temp = str(itemID)
     query = "DELETE FROM cart WHERE cartID = (?) AND objectID = (?)"
     c.execute(query,(current_user.id,temp))
     conn.commit()

     items_query = "SELECT * FROM cart,item WHERE cartID = (?) AND item.itemID IN( SELECT itemID FROM item WHERE itemID = objectID)"
     c.execute(items_query, str(current_user.id))
     items = c.fetchall()
     matching_items_images = item_name_path(items)
     
     sum = 0
     for x in items:
         sum = sum + x['price'] 
     return render_template('cart.html', items = items, matching_items_images = matching_items_images, length = len(items), total = sum, title = 'cart')


if __name__ == '__main__':
    app.run(debug=True)

