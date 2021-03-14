from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, BooleanField, TextField, TextAreaField, SelectField,  IntegerField, DecimalField
from wtforms.validators import DataRequired, Length, Email, EqualTo


class RegistrationForm(FlaskForm):
    firstName = StringField('First Name', validators=[DataRequired(), Length(min=2, max=50)])
    lastName = StringField('Last Name', validators=[DataRequired(), Length(min=2, max=50)])
    email = StringField('Email',validators=[Email(), DataRequired()])
    phoneNumber = StringField('Phone Number', validators=[DataRequired(), Length(min=2, max=50)])
    password = PasswordField('Password', validators=[DataRequired()])
    confirm_password = PasswordField('Confirm Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Sign Up')

class AddForm(FlaskForm):
    itemid = IntegerField('itemid', validators=[DataRequired()])
    itemName = StringField('itemName', validators=[DataRequired()])
    brand = StringField('brand', validators=[DataRequired()])
    size = DecimalField('size', validators=[DataRequired()])
    price = DecimalField('price', validators=[DataRequired()])
    stock = IntegerField('stock', validators=[DataRequired()])
    submit = SubmitField('Add')

class LoginForm(FlaskForm):
    email = StringField('Email',validators=[Email(), DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember = BooleanField('Remember Me')
    submit = SubmitField('Login')


# class BlogForm(FlaskForm):
#     username = SelectField('Username', choices=[], coerce=int)
#     title = StringField('Title', validators=[DataRequired()])
#     content = TextAreaField('Content', validators=[DataRequired()])
#     submit = SubmitField('Submit')