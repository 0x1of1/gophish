![gophish logo](https://raw.github.com/gophish/gophish/master/static/images/gophish_purple.png)

# Gophish

Build Status GoDoc

Gophish: Open-Source Phishing Toolkit

Gophish is an open-source phishing toolkit designed for businesses and penetration testers. It provides the ability to quickly and easily setup and execute phishing engagements and security awareness training.

## Quick Deploy on Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

### Render Deployment Steps

1. **Fork this repository** to your GitHub account
2. **Connect to Render**: 
   - Go to [render.com](https://render.com) and sign up/login
   - Click "New +" and select "Web Service"
   - Connect your GitHub repository
3. **Configure the service**:
   - **Name**: `gophish` (or your preferred name)
   - **Environment**: `Docker`
   - **Branch**: `master`
   - **Build Command**: `docker build -t gophish .`
   - **Start Command**: `docker run -p $PORT:3333 gophish`
4. **Deploy**: Click "Create Web Service"

The service will automatically build and deploy. Once complete, you'll get a URL like `https://your-app-name.onrender.com`.

### First Login

After deployment, access your Gophish instance and login with:
- **Username**: `admin`
- **Password**: Check the Render logs for the generated password

### Environment Variables

You can configure these environment variables in Render:
- `GIN_MODE`: Set to `release` for production

## Local Development

### Install

Installation of Gophish is dead-simple - just download and extract the zip containing the release for your system, and run the binary. Gophish has binary releases for Windows, Mac, and Linux platforms.

### Building From Source

**If you are building from source, please note that Gophish requires Go v1.21 or above!**

To build Gophish from source, simply run `git clone https://github.com/gophish/gophish.git` and `cd` into the project source directory. Then, run `go build`. After this, you should have a binary called `gophish` in the current directory.

### Docker

You can also use Gophish via Docker:

```bash
# Build and run with docker-compose
docker-compose up --build

# Or build manually
docker build -t gophish .
docker run -p 3333:3333 -p 80:80 gophish
```

### Setup

After running the Gophish binary, open an Internet browser to <https://localhost:3333> and login with the default username and password listed in the log output. e.g.

```
time="2020-07-29T01:24:08Z" level=info msg="Please login with the username admin and the password 4304d5255378177d"
```

Releases of Gophish prior to v0.10.1 have a default username of `admin` and password of `gophish`.

## Documentation

Documentation can be found on our site. Find something missing? Let us know by filing an issue!

## Issues

Find a bug? Want more features? Find something missing in the documentation? Let us know! Please don't hesitate to file an issue and we'll get right on it.

## License

```
Gophish - Open-Source Phishing Framework

The MIT License (MIT)

Copyright (c) 2013 - 2020 Jordan Wright

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software ("Gophish Community Edition") and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

```
