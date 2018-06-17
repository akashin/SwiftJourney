/*
Su Doku (Japanese meaning number place) is the name given to a popular puzzle concept.
Its origin is unclear, but credit must be attributed to Leonhard Euler who invented a similar,
and much more difficult, puzzle idea called Latin Squares. The objective of Su Doku puzzles,
however, is to replace the blanks (or zeros) in a 9 by 9 grid in such that each row, column,
and 3 by 3 box contains each of the digits 1 to 9. Below is an example of a typical starting
puzzle grid and its solution grid.

A well constructed Su Doku puzzle has a unique solution and can be solved by logic, although
it may be necessary to employ "guess and test" methods in order to eliminate options
(there is much contested opinion over this). The complexity of the search determines the
difficulty of the puzzle; the example above is considered easy because it can be solved by
straight forward direct deduction.

The 6K text file, sudoku.txt (right click and 'Save Link/Target As...'), contains fifty different
Su Doku puzzles ranging in difficulty, but all with unique solutions (the first puzzle in the file
is the example above).

By solving all fifty puzzles find the sum of the 3-digit numbers found in the top left corner of
each solution grid; for example, 483 is the 3-digit number found in the top left corner of the
solution grid above.

https://projecteuler.net/problem=96

Answer:
  24702

Time before optimization:
./96.out  24.50s user 0.01s system 99% cpu 24.519 total

Time after optimization with lazy collections:
./96.out  13.27s user 0.00s system 99% cpu 13.284 total

Time after optimization with bitmask instead of Array in hadDuplicates:
./96.out  2.73s user 0.01s system 99% cpu 2.751 total

Allocations are quite expensive!
*/

import Foundation

let test_grid_string = """
003020600
900305001
001806400
008102900
700000008
006708200
002609500
800203009
005010300
"""

let kZeroCode: UInt32 = 48
let kNineCode: UInt32 = kZeroCode + 9

extension UnicodeScalar {
  var isDigit: Bool {
    return self.value >= kZeroCode && self.value <= kNineCode
  }

  var asDigit: Int {
    return Int(self.value - kZeroCode)
  }
}

struct Grid: CustomStringConvertible {
  var grid = Array<Array<Int>>(repeating: Array<Int>(repeating: 0, count: 9), count: 9)

  subscript(row: Int, column: Int) -> Int {
    get {
      return grid[row][column]
    }
    set {
      grid[row][column] = newValue
    }
  }

  func row(_ index: Int) -> LazyMapCollection<ClosedRange<Int>, Int> {
    return (0...8).lazy.map { self.grid[index][$0] }
  }

  func column(_ index: Int) -> LazyMapCollection<ClosedRange<Int>, Int> {
    return (0...8).lazy.map { self.grid[$0][index] }
  }

  func sector(_ index: Int) -> LazyMapCollection<ClosedRange<Int>, Int> {
    let row_start = 3 * (index / 3)
    let column_start = 3 * (index % 3)
    return (0...8).lazy.map { self.grid[row_start + $0 / 3][column_start + $0 % 3] }
  }

  var description: String {
    return grid.map({ $0.description }).joined(separator: "\n")
  }
}

func parseGrid(_ grid_string: String) -> Grid {
  var grid = Grid()
  for (row, line) in grid_string.split(separator: "\n").enumerated() {
    for (column, digit) in line.unicodeScalars.map({ $0.asDigit }).enumerated() {
      grid[row, column] = digit
    }
  }
  return grid
}

func hasDuplicates<T: Sequence>(_ array: T) -> Bool
  where T.Element == Int {
    var digit_mask = 0
    for value in array {
      if value != 0 {
        let bit = 1 << (value - 1)
        if digit_mask & bit > 0 {
          return true
        }
        digit_mask |= bit
      }
    }
    return false
}

func anyTrue<T: Sequence>(_ array: T) -> Bool
  where T.Element == Bool {
    return array.reduce(false, { $0 || $1 })
}

func validateGrid(_ grid: Grid) -> Bool {
  return anyTrue((0...8).lazy.map { hasDuplicates(grid.column($0)) })
      || anyTrue((0...8).lazy.map { hasDuplicates(grid.row($0)) })
      || anyTrue((0...8).lazy.map { hasDuplicates(grid.sector($0)) })
}

func solveGrid(_ input_grid: Grid) -> Grid {
  var grid = input_grid
  func fillGrid(row: Int, column: Int) -> Bool {
    if validateGrid(grid) {
      return false
    }

    if row >= 9 {
      return true
    }
    if column >= 9 {
      return fillGrid(row: row + 1, column: 0)
    }
    if grid[row, column] != 0 {
      return fillGrid(row: row, column: column + 1)
    }

    for digit in 1...9 {
      grid[row, column] = digit
      if fillGrid(row: row, column: column + 1) {
        return true
      }
      grid[row, column] = 0
    }
    return false
  }
  if !fillGrid(row: 0, column: 0) {
    print("Failed to fill grid")
  }
  return grid
}

func readGrids(_ filename: String) -> Array<Grid> {
  var grids = Array<Grid>()

  let file_handle = FileHandle(forReadingAtPath: filename)!
  let data = file_handle.readDataToEndOfFile()
  let lines = String(data: data, encoding: .utf8)!.split(separator: "\n")

  let block_size = 10
  for block_index in 0..<(lines.count / block_size) {
    let block_start = block_index * block_size
    let next_block_start = (block_index + 1) * block_size
    let block_lines = lines[block_start + 1..<next_block_start]
    grids.append(parseGrid(block_lines.joined(separator: "\n")))
  }
  return grids
}

func extractNumber(_ grid: Grid) -> Int {
  return grid[0, 0] * 100 + grid[0, 1] * 10 + grid[0, 2] * 1
}

let grids = readGrids("sudoku.txt")
print("Read \(grids.count) grids")

var answer = 0
for (index, grid) in grids.enumerated() {
  let solved_grid = solveGrid(grid)
  answer += extractNumber(solved_grid)
  print("Solved grid \(index)")
}
print(answer)
