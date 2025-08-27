use aiken/list

// Simple compilation test
test basic_compilation_test() {
  True
}

// Test list operations work
test list_operations() {
  let signatories = [#"abc123", #"def456"]
  let target = #"abc123"
  list.has(signatories, target)
}

// Test string comparison
test string_comparison() {
  let message = "Hello, World!"
  message == "Hello, World!"
}
