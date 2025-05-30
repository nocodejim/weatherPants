#!/bin/bash

# 1. Define the API key and city ID.
API_KEY="3a7ab9b9e0fb8efbc4320ec5173d9ce1"
CITY_ID="5128581" # New York City

# 2. Construct the API URL.
URL="http://api.openweathermap.org/data/2.5/weather?id=${CITY_ID}&appid=${API_KEY}&units=metric"

# 3. Print the URL that will be used (for debugging purposes).
echo "Requesting URL: $URL"

# 4. Make the API request using curl.
#    - Save the output to a temporary file.
#    - Check the exit code of curl to determine if the request was successful.
curl -sSf "$URL" > /tmp/weather_api_test_output.json
CURL_EXIT_CODE=$?

# 5. Analyze the result.
if [ $CURL_EXIT_CODE -eq 0 ]; then
  echo "API request successful!"
  echo "First 5 lines of the output:"
  head -n 5 /tmp/weather_api_test_output.json
  if grep -q '"cod":200' /tmp/weather_api_test_output.json; then
    echo "OpenWeatherMap success code (cod: 200) found."
  else
    echo "OpenWeatherMap success code (cod: 200) NOT found."
  fi
else
  echo "API request failed. Curl exit code: $CURL_EXIT_CODE"
fi

# 6. Clean up the temporary file.
rm -f /tmp/weather_api_test_output.json
