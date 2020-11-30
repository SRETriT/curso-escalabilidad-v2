# Requirements

- python > 3



# Install requirements

```bash
$> python3 -m venv venv
$> . venv/bin/activate
$(venv)> pip3 install -t requirements.txt
```


# Run application (single core)

```bash
$(venv)> gunicorn 'server-remote:create_app()'
```
