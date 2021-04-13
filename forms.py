from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, BooleanField, TextField, RadioField, HiddenField, TextAreaField, SelectField,  IntegerField, DecimalField
from wtforms.validators import DataRequired, Length, Email, EqualTo


class RegistrationForm(FlaskForm):
    firstName = StringField('First Name *', validators=[DataRequired(), Length(min=2, max=50)])
    lastName = StringField('Last Name *', validators=[DataRequired(), Length(min=2, max=50)])
    email = StringField('Email *', validators=[Email(), DataRequired()])
    street_address = StringField('Street Address', validators=[Length(max=255)])
    province = SelectField('Province', choices=['BC', 'AB', 'ON', 'NL', 'PE', 'NS', 'NB', 'QC', 'MB', 'SK', 'YT', 'NT', 'NU'])
    city = StringField('City', validators=[Length(max=255)])
    zip_code = StringField('Zip Code', validators=[Length(max=6)])
    birthdate = StringField('Birthdate', validators=[Length(max=10)])
    password = PasswordField('Password *', validators=[DataRequired()])
    confirm_password = PasswordField('Confirm Password *', validators=[DataRequired(), EqualTo('password', message='Passwords do not match')])
    submit = SubmitField('Sign Up')

class AddForm(FlaskForm):
    itemid = IntegerField('itemid', validators=[DataRequired()])
    itemName = StringField('itemName', validators=[DataRequired()])
    brand = StringField('brand', validators=[DataRequired()])
    size = DecimalField('size', validators=[DataRequired()])
    price = DecimalField('price', validators=[DataRequired()])
    stock = IntegerField('stock', validators=[DataRequired()])
    submit = SubmitField('Add')

class LoginForm(RegistrationForm):
    remember = BooleanField('Remember Me')
    submit = SubmitField('Login')

class TimeSelectForm(FlaskForm):
    timeInput = RadioField('Time Period', choices=[('All', 'All Orders'), ('SevenDays', '7 Days'), ('OneMonth', '1 Month')], default='All')
    submit = SubmitField('')

class EditInformationForm(RegistrationForm):
    update = SubmitField('Update')

class changePasswordForm(FlaskForm):
    old_password = PasswordField('Old Password *', validators=[DataRequired()])
    new_password = PasswordField('New Password *', validators=[DataRequired()])
    confirm_password = PasswordField('Confirm Password *', validators=[DataRequired(), EqualTo('new_password', message='Password confirmation does not match new password')])
    update_password = SubmitField('Update Password')