from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, BooleanField, SelectField, RadioField
from wtforms.validators import DataRequired, Length, Email, EqualTo


class RegistrationForm(FlaskForm):
    firstName = StringField('First Name', validators=[DataRequired(), Length(min=2, max=50)])
    lastName = StringField('Last Name', validators=[DataRequired(), Length(min=2, max=50)])
    email = StringField('Email',validators=[Email(), DataRequired()])
    address = StringField('Address', validators=[Length(min=2, max=255)])
    birthdate = StringField('Birthdate', validators=[Length(min=2, max=255)])
    password = PasswordField('Password', validators=[DataRequired()])
    confirm_password = PasswordField('Confirm Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Sign Up')

class LoginForm(FlaskForm):
    email = StringField('Email',validators=[Email(), DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember = BooleanField('Remember Me')
    submit = SubmitField('Login')

class TimeSelectForm(FlaskForm):
    timeInput = RadioField('Time Period', choices=[('All', 'All Orders'), ('SevenDays', '7 Days'), ('OneMonth', '1 Month')], default='All')
    submit = SubmitField('')
    test = RadioField()


# class BlogForm(FlaskForm):
#     username = SelectField('Username', choices=[], coerce=int)
#     title = StringField('Title', validators=[DataRequired()])
#     content = TextAreaField('Content', validators=[DataRequired()])
#     submit = SubmitField('Submit')