# Use an official lightweight web server image
FROM nginx:alpine

# Copy static webapp files (assuming the webapp is a static Angular app)
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
