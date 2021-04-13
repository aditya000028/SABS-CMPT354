from flask_login import UserMixin

class Member(UserMixin):
    def __init__(self, id, fname, lname, email, password, points, registeredDate, companyName, address_street, address_city, address_zip, address_province, birthdate):
        self.id = id
        self.fname = fname
        self.lname = lname
        self.email = email
        self.password = password
        self.points = points
        self.registeredDate = registeredDate
        self.companyName = companyName
        self.address_street = address_street
        self.address_city = address_city
        self.address_zip = address_zip
        self.address_province = address_province
        self.birthdate = birthdate
        self.authenticated = False

    def is_active(self):
        return True

    def is_anonymous(self):
        return False

    def is_authenticated(self):
        return self.authenticated

    def get_id(self):
        return self.id

    def is_employee(self):
        return False