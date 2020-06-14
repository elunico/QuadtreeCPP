if [[ $1 == "debug" ]]; then
  g++ -O0 -g -Wall -DDEBUG -Iinclude/ -o main ./src/*.cpp
else
  g++ -O3 -Iinclude/ -o main ./src/*.cpp
fi
