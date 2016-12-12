import * as React from "react";
import {Action} from "../actions";
import * as Domain from "../gameObjects"

export interface CellProps {
    cell: Domain.Cell
    onMovePlayed: (col: number) => any
}
export const Cell = (props: CellProps) => {
    let playMove = (col: number) => (event) => {
        event.preventDefault();
        props.onMovePlayed(col);
        // dispatch playMove event in column to Store
    }
    return <div className={`cell ${props.cell.value}`} onClick={playMove(props.cell.col)}></div>
}

export interface RowProps {
    row: Array<Domain.Cell>
    onMovePlayed: (col: number) => any
}
export const Row = (props: RowProps) => {
    let renderedCells = props.row.map(cell => <Cell cell={cell} key={`${cell.col},${cell.row}`} onMovePlayed={props.onMovePlayed}></Cell>);
    let rowNum = props.row[0].row;
    return <div className={`row row-${rowNum}`}>
        {renderedCells}
    </div>
}

interface BoardProps {
    board: Domain.Board,
    onMovePlayed: (col: number) => any
}
export const Board = (props: BoardProps) => {
    let renderedRows = props.board.map((row: Domain.Cell[], index) => <Row row={row} key={index} onMovePlayed={props.onMovePlayed}></Row>)
    return <div className="board">
        {renderedRows}
    </div>
}
