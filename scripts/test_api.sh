#!/bin/bash

# Check if an API key is provided
if [ -z "$1" ]; then
  echo "Usage: $0 YOUR_API_KEY"
  exit 1
fi

API_KEY=$1
CITY_ID="5128581" # New York City as an example, replace if needed
URL="http://api.openweathermap.org/data/2.5/weather?id=${CITY_ID}&appid=${API_KEY}&units=metric"

echo "Testing API key: $API_KEY"
echo "Requesting URL: $URL"
echo ""

# Make the API request using curl
# -s for silent (no progress meter)
# -S to show error message if it fails
# -f to fail silently on server errors (HTTP 4xx, 5xx)
# We can check the exit code of curl to see if it was successful (0) or not
curl -sSf "$URL" > /tmp/weather_api_test_output.json

if [ $? -eq 0 ]; then
  echo "API request successful!"
  echo "Response (first 5 lines):"
  head -n 5 /tmp/weather_api_test_output.json
  echo ""
  echo "To see the full response, check /tmp/weather_api_test_output.json"
  echo "If you see weather data, your API key is likely working."
  # Basic check for "cod: 200" in the JSON, typical for OpenWeatherMap success
  if grep -q '"cod":200' /tmp/weather_api_test_output.json; then
    echo "OpenWeatherMap success code (cod: 200) found in response."
  else
    echo "WARNING: OpenWeatherMap success code (cod: 200) NOT found in response. The key might be invalid or have issues."
  fi
else
  echo "API request failed. This could be due to an invalid API key, network issues, or the API endpoint being unavailable."
  echo "Curl exit code: $?"
  echo "If you received a 401 error, your API key is likely invalid or not activated."
  echo "If you received a 404 error, the city ID or API endpoint might be incorrect."
  echo "Check the output above for any specific error messages from curl."
fi

# Clean up the temporary file
rm -f /tmp/weather_api_test_output.json
