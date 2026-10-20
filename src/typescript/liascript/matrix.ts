// Matrix quizzes and surveys: the arrow keys move the focus to the neighboring
// cell. Left and right in a row of radio buttons stay with the browser, which
// also selects them. Captured and prevented, so the slides do not change (see
// arrowsInUse in service/Swipe.ts).

const MOVES: { [key: string]: [number, number] } = {
  ArrowUp: [-1, 0],
  ArrowDown: [1, 0],
  ArrowLeft: [0, -1],
  ArrowRight: [0, 1],
}

document.addEventListener(
  'keydown',
  (event: KeyboardEvent) => {
    const move = MOVES[event.key]
    const input = event.target as HTMLInputElement

    if (
      !move ||
      event.altKey ||
      event.ctrlKey ||
      event.metaKey ||
      !input ||
      !input.matches ||
      !input.matches('.lia-survey-matrix input') ||
      (move[1] !== 0 && input.type === 'radio')
    )
      return

    // also at the borders, otherwise the browser would select the previous or
    // next radio button of the row or the slides would change
    event.preventDefault()

    const cell = input.parentElement as HTMLTableCellElement
    const row = cell.parentElement as HTMLTableRowElement
    const next = (
      move[0] < 0
        ? row.previousElementSibling
        : move[0] > 0
          ? row.nextElementSibling
          : row
    ) as HTMLTableRowElement | null

    const rtl = getComputedStyle(row).direction === 'rtl'
    const column = cell.cellIndex + (rtl ? -move[1] : move[1])

    next?.cells[column]?.querySelector('input')?.focus()
  },
  true
)
