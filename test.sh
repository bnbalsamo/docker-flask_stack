#!/bin/bash
echo "Building Template..."
docker build . -t flask_stack_test && \
echo "Cloning Demo..." && \
git clone https://github.com/bnbalsamo/flask_stack_minimal_demo.git || exit 1 
cd flask_stack_minimal_demo || exit 1 
echo "Altering demo Dockerfile"
cat Dockerfile | sed 's/bnbalsamo\/flask_stack/flask_stack_test/g' > Dockerfile.test
echo "Building Demo..." 
docker build . --file Dockerfile.test -t my_demo_test || exit 1 
echo "Running Demo..."
docker run -d -p 5000:80 my_demo_test || exit 1
sleep 3
echo "It's running!" 
echo "curling for status code..." 
response=$(curl --write-out %{http_code} --silent --output /dev/null localhost:5000) 
echo $response 
if [[ $response -ne 200 ]]; then echo "$response" && exit 1; fi || exit 1 
echo "curling for content..."
response=$(curl --silent localhost:5000)
echo "$response"
if [[ $response != "Hello, World"'!' ]]; then echo "$response" && exit 1; fi || exit 1
echo "All good!"
exit 0
