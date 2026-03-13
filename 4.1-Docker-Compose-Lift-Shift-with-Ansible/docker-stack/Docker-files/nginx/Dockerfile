## Dockerfile for Nginx web server container    
FROM nginx:1.25.3

## Metadata
LABEL project="vprofile-Strata-Ops"
LABEL Author="Amr M. Amer"

## Remove default Nginx configuration and add custom configuration for the vprofile application
RUN rm -rf /etc/nginx/conf.d/default.conf

## Copy custom Nginx configuration file for the vprofile application
COPY nginx-vproapp.conf /etc/nginx/conf.d/vproapp.conf