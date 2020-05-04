import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_cooked/model/recipe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test('Section parser should parse list with no headings', () {
    var sections = Section.fromMarkup(["a", "b", "c", "d"]);
    expect(sections, containsAllInOrder(
        [Section(null, ["a", "b", "c", "d"])]));
  });

  test('Section parser should return empty for empty list', () {
    var sections = Section.fromMarkup([]);
    expect(sections, hasLength(0));
  });

  test('Section parser should return empty for null list', () {
    var sections = Section.fromMarkup(null);
    expect(sections, hasLength(0));
  });

  test('Section parser should parse list with heading in the middle', () {
    var sections = Section.fromMarkup(["a", "b", "*c*", "d"]);
    expect(sections, containsAllInOrder([
      Section(null, ["a", "b"]),
      Section("c", ["d"]),
    ]));
  });

  test('Section parser should parse list with multipe headings', () {
    var sections = Section.fromMarkup(["*a*", "b", "*c*", "d"]);
    expect(sections, containsAllInOrder([
      Section("a", ["b"]),
      Section("c", ["d"]),
    ]));
  });

  test('Section parser should parse list with heading at end', () {
    var sections = Section.fromMarkup(["*a*", "b", "c", "*d*"]);
    expect(sections, containsAllInOrder([
      Section("a", ["b", "c"]),
      Section("d", []),
    ]));
  });

  test('Section parser should ignore comments', () {
    var sections = Section.fromMarkup(["//a", "b", "*c*", "//d"]);
    expect(sections, containsAllInOrder([
      Section(null, ["b"]),
      Section("c", []),
    ]));
  });

  test('Section parser should remove blank lines at the beginning or end', () {
    var sections = Section.fromMarkup(["*a*", "", "b", ""]);
    expect(sections, containsAllInOrder([
      Section("a", ["b"]),
    ]));
  });

  test('Section parser should remove only one blank line if there is only one item', () {
    var sections = Section.fromMarkup(["*a*", ""]);
    expect(sections, containsAllInOrder([
      Section("a", []),
    ]));
  });

  test('Section parser should treat new lines in the middle as new sections', () {
    var sections = Section.fromMarkup(["*a*", "b", "c", "", "d", "e", " ", "f", "g"]);
    expect(sections, containsAllInOrder([
      Section("a", ["b", "c"]),
      Section(null, ["e", "e"]),
      Section(null, ["f", "g"]),
    ]));
  });

}
