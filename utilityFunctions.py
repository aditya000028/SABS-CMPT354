import sqlite3

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

# Get a connection to the database
def db_connection():
    conn = sqlite3.connect('sabs.db')
    conn.row_factory = dict_factory

    return conn

# Get the path for every item's image
def item_name_path(list_of_something):
    # Create the path to display images
    itemNamesList = []
    for x in list_of_something:
        name = "../static/images/"
        name = name + str(x["itemName"]).replace(" ", "")
        name = name + ".png"
        itemNamesList.append(name)

    return itemNamesList

# Check if the email is unique
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

# Calculate the new price of the item after applying company discount and member points
# Our policy is that on every tenth purchase, we give the member a 10% discount 
# on whatever product they are buying
def calculate_new_price(user_points, current_price, discount_percent):
    if user_points == 10:
        new_price = current_price - (current_price * (float(discount_percent/100) + float(user_points/100)) )
    else:
        new_price = current_price - (current_price * (float(discount_percent/100)) )
    return [current_price, discount_percent, new_price]

