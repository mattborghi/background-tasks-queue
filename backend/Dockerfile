# Run/build as follows
# docker build -t backend:latest .
# docker run -d --name django-heroku -e "PORT=3000" -e "DEBUG=1" -p 8007:3000 backend:latest

# Pull a base image
FROM python:3.9

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DEBUG 0

# Create a working directory for the django project
WORKDIR /backend

# Copy requirements to the container
COPY Pipfile Pipfile.lock /backend/

# Install the requirements to the container
RUN pip install pipenv && pipenv install

# Copy the project files into the working directory
COPY . /backend/

# run gunicorn
CMD pipenv run gunicorn app.wsgi:application --bind 0.0.0.0:$PORT