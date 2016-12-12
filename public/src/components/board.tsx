import * as React from "react";
import * as Domain from "../gameObjects"

export interface CellProps {
    cell: Domain.Cell
}
export const Cell = (props: CellProps) => {
    let playMove = (col: number) => (event) => {
        event.preventDefault();
        // dispatch playMove event in column to Store
    }
    return <div className={`cell ${props.cell.value}`} onClick={playMove(props.cell.x)}></div>
}

export interface RowProps {
    row: Array<Domain.Cell>
}
export const Row = (props: RowProps) => {
    let renderedCells = props.row.map(cell => <Cell cell={cell} key={`${cell.x},${cell.y}`}/>);
    let rowNum = props.row[0].y;
    return <div className={`row row-${rowNum}`}>
        {renderedCells}
    </div>
}

interface BoardProps {
    board: Domain.Board
}
export const Board = (props: BoardProps) => {
    let renderedRows = props.board.map((row: Domain.Cell[], index) => <Row row={row} key={index}></Row>)
    return <div className="board">
        {renderedRows}
    </div>
}
