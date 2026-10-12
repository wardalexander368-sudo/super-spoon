const input = document.getElementById('q');
const list = document.getElementById('results');

input.addEventListener('input', async () => {
  const hits = await window.notes.search(input.value);
  list.replaceChildren(...hits.map((h) => Object.assign(document.createElement('li'), { textContent: h.title })));
});
