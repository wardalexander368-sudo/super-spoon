const NOTES = [
  { id: 1, title: 'Groceries', body: 'eggs, milk, coffee' },
  { id: 2, title: 'Ideas', body: 'reverse engineer the search feature' },
];

function normalize(text) {
  return text.toLowerCase().normalize('NFKD');
}

function searchNotes(query) {
  const q = normalize(query);
  return NOTES.filter((n) => normalize(n.title + ' ' + n.body).includes(q));
}

module.exports = { searchNotes };
