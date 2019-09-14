const fs = require("fs")
const readline = require("readline")

console.log("local stations = {")

const reader = readline.createInterface({
    input: fs.createReadStream("./trains4.dat"),
})

let currentLine = 0

reader.on("line", (line) => {
    const params = line.split(" ")
    const curLine = currentLine++

    if(params[3] && [1, 5].includes(Number(params[3]))){
        console.log(`\t{ node = ${curLine}, name = "" },`)
    }
})

reader.on("close", () => {
    console.log("}")
})