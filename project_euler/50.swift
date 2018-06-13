/*
The prime 41, can be written as the sum of six consecutive primes:
  41 = 2 + 3 + 5 + 7 + 11 + 13

This is the longest sum of consecutive primes that adds to a prime below one-hundred.

The longest sum of consecutive primes below one-thousand that adds to a prime, contains 21 terms,
and is equal to 953.

Which prime, below one-million, can be written as the sum of the most consecutive primes?

https://projecteuler.net/problem=50
*/

func findPrimes(limit: Int) -> [Int] {
  var primes: [Int] = []
  var sieved = Array(repeating: false, count: limit + 1)

  for i in 2...limit {
    if !sieved[i] {
      primes.append(i)
      var j = 2 * i
      while j <= limit {
        sieved[j] = true
        j += i
      }
    }
  }

  return primes
}

func findMaxSeriesLength(primes: [Int]) -> Int {
  var sum = 0
  var index = 0
  while sum < primes.last! {
    sum += primes[index]
    index += 1
  }
  return index
}

func findPrimeWithLongestSequence(limit: Int) -> (prime: Int, length: Int) {
  let primes = findPrimes(limit: limit)
  print("Primes count:", primes.count)
  print("Last prime:", primes.last!)

  let max_length = findMaxSeriesLength(primes: primes)
  print("Max series length:", max_length)

  var max_prime_with_sequence = 0
  var max_prime_sequence_length = 0

  let primes_set = Set(primes)
  for i in 0..<primes.count {
    var sum = 0
    for j in 0..<max_length {
      sum += primes[i + j]
      if sum > primes.last! || i + j + 1 >= primes.count {
        break
      }
      if primes_set.contains(sum) {
        if j + 1 > max_prime_sequence_length {
          max_prime_sequence_length = j + 1
          max_prime_with_sequence = sum
        }
      }
    }
  }

  return (max_prime_with_sequence, max_prime_sequence_length)
}

print(findPrimeWithLongestSequence(limit: 1000000))
