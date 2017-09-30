#!/bin/bash
python manage.py check
python manage.py loaddata navbar
python manage.py loaddata language_small
