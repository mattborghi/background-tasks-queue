# Run/build as follows
# docker build -t backend:latest .
# docker run -d --name django-heroku -e "PORT=3000" -e "DEBUG=1" -p 8007:3000 backend:latest
# docker rm -f django-heroku

# Pull a base image
FROM python:3.9

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DEBUG 0

# Create a working directory for the django project
WORKDIR /backend

# Install the requirements to the container
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# Copy the project files into the working directory
COPY . /backend/

RUN python manage.py collectstatic --noinput && python manage.py migrate --noinput

# run gunicorn
CMD gunicorn app.wsgi:application --bind 0.0.0.0:${PORT}