use hello_world/hello_world.{add, hello_world}

// Test the hello_world function
test hello_world_test() {
  hello_world() == "Hello, World!"
}

// Test the add function
test add_test() {
  add(2, 3) == 5
}

// Test basic compilation
test basic_compilation_test() {
  True
}
