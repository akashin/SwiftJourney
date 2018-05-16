/*
Louise joined a social networking site to stay in touch with her friends.
The signup page required her to input a name and a password. However, the password must be strong.
The website considers a password to be strong if it satisfies the following criteria:

    Its length is at least .
    It contains at least one digit.
    It contains at least one lowercase English character.
    It contains at least one uppercase English character.
    It contains at least one special character. The special characters are: !@#$%^&*()-+

She typed a random string of length in the password field but wasn't sure if it was strong.
Given the string she typed, can you find the minimum number of characters she must add to make
her password strong?
*/

let numbers = "0123456789"
let lower_case = "abcdefghijklmnopqrstuvwxyz"
let upper_case = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
let special_characters = "!@#$%^&*()-+"

func extendToStrongPassword(_ password: String) -> String {
  var new_password = password

  for collection in [numbers, lower_case, upper_case, special_characters] {
    if new_password.filter({ collection.contains($0) }).isEmpty {
      new_password.append(collection[collection.startIndex])
    }
  }

  new_password += String(repeating: "!", count: max(6 - new_password.count, 0))

  return new_password
}

if let password = readLine() {
  print(extendToStrongPassword(password))
}
