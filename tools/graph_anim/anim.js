var stopClock = false

const EventGraph = Object.freeze({
    "addNode": 1,
    "addEdge": 2,
    "packetSend": 3,

    "removeNode": 4,
    "removeEdge": 5,
    "packetReceive": 6,

    "stateNode": 7
})

function submit() {
    var textInput = document.getElementById('textInput');
    var text = textInput.value
    if (text == null) {
        text = text.innerHTML
    }

    var timeline = parseLog(text)
    console.log(timeline)
    graph(timeline, 0.25)

}

function parseLog(text) {
    lines = text.split("\n")
    first_time = new Date(lines[0].split(" ")[0] + "T" + lines[0].split(" ")[1])

    function createOneTime(time_b, data) {
        return {
            begin: time_b - first_time,
            data: data
        }
    }

    var timeline = []
    for (var i = 1; i < lines.length; i++) {
        words = lines[i].split(" ")
        time_l = new Date(words[0] + "T" + words[1])

        removed = words.splice(0, 4) // two spaces between (id_daemon) and log line
        log_line = words.join(" ")
        //console.log(log_line)
        if (words[0] == "ANIM") {
            if (words[1] == "START") {
                timeline.push(createOneTime(time_l, {
                    type: EventGraph.addNode,
                    label: "Job " + words[2],
                    id: words[2]
                }))

            } else if (words[1] == "STATE") {
                timeline.push(createOneTime(time_l, {
                    type: EventGraph.stateNode,
                    id_node: words[2],
                    color: "#000000"
                }))

            } else if (words[1] == "CONNETED") {
                timeline.push(createOneTime(time_l, {
                    type: EventGraph.addEdge,
                    to: words[2],
                    from: words[4]
                }))

            } else if (words[1] == "SDATA") {
                timeline.push(createOneTime(time_l, {
                    type: EventGraph.packetSend,
                    to: words[2],
                    from: words[4],
                    packet: words[8]
                }))

            } else if (words[1] == "RDATA") {
                timeline.push(createOneTime(time_l, {
                    type: EventGraph.packetReceive,
                    to: words[2],
                    from: words[4],
                    packet: words[8]
                }))

            } else if (words[1] == "EXIT") {
                timeline.push(createOneTime(time_l, {
                    type: EventGraph.removeNode,
                    id: words[2]
                }))

            } else if (words[1] == "DISCONNETED") {
                timeline.push(createOneTime(time_l, {
                    type: EventGraph.removeEdge,
                    to: words[2],
                    from: words[4]
                }))
            } else {
                console.log("Type of ANIM unknown : " + words[0])
            }
        } else if (words[0] == "CRASH") {

        }
    }

    function compare(a, b) {
        return a.begin - b.begin;
    }

    // return a timeline
    return timeline.sort(compare)
}


function graph(timeline, speedFactor) {

    const sleep = (milliseconds) => {
        return new Promise(resolve => setTimeout(resolve, milliseconds))
    }

    var counterNode = 1;

    var nodes = new vis.DataSet([]);
    var edges = new vis.DataSet([]);

    // create a network
    var container = document.getElementById('network');
    var data = {
        nodes: nodes,
        edges: edges
    };
    var options = {
        physics: {
            maxVelocity: 10,
            solver: 'repulsion',
            repulsion: {
                centralGravity: 0.5,
                springConstant: 0.01,
                nodeDistance: 150
            }
        }
    };
    var network = new vis.Network(container, data, options);
    var packets = {}

    function resolveOneTime(timedata) {
        if (timedata.type === EventGraph.addNode) {
            const idNode = counterNode;
            nodes.add({
                id: idNode,
                label: timedata.label,
                borderWidth: 3,
                font: {
                    size: 20
                }
            })

            counterNode += 1;
        } else if (timedata.type === EventGraph.addEdge) {
            const idEdge = "" + timedata.to + "-" + timedata.from
            edges.add({
                to: timedata.to,
                from: timedata.from,
                arrows: "to",
                width: 2,
                id: idEdge,
                length: 300,
                // smooth: false

            })
            packets[idEdge] = {nb: 0, labels: []} 
        } else if (timedata.type === EventGraph.packetSend) {
            const idEdge = "" + timedata.to +"-"+timedata.from

            packets[idEdge].nb += 1 

            edges.update([{ width: 3 + packets[idEdge].nb, id: idEdge, color: {
                color: "#000000",
                highlight: "#000000",
                hover: "#000000",
                inherit: false,
                opacity: 1.0
            }}])

        } else if (timedata.type === EventGraph.packetReceive) {
            const idEdge = "" + timedata.from +"-"+ timedata.to 
            packets[idEdge].nb -= 1
            if ( packets[idEdge].nb == 0) {
                edges.update([{ width: 2, id: idEdge, color: {
                    color: '#2B7CE9',
                    highlight: '#2B7CE9',
                    hover: '#2B7CE9',
                    inherit: 'from',
                    opacity: 1.0
                }}])
            } else {
                edges.update([{ width: 3 + packets[idEdge].nb, id: idEdge, color: {
                    color: "#000000",
                    highlight: "#000000",
                    hover: "#000000",
                    inherit: false,
                    opacity: 1.0
                }}])
            }
        } else if (timedata.type === EventGraph.removeNode) {
            nodes.remove(timedata.id)
        } else if (timedata.type === EventGraph.removeEdge) {
            const idEdge = "" + timedata.to + "-" + timedata.from
            edges.remove(idEdge)
            packets[idEdge] = {}
        } else {
            console.log("Not implemented type : " + timedata.type)
        }
    }

    const executeTimeline = async () => {

        var date = new Date();
        var beginTime = date.getTime();
        index = 0;
        var c = new Clock(250, speedFactor)
        c.updateStartTime(beginTime)
        c.start()
        while (timeline.length > index) {
            var timestamp = Date.now();
            timeToWait = (timeline[index].begin / speedFactor - (timestamp - beginTime));
            if (timeToWait >= 0) {
                await sleep(timeToWait);
            }
            console.log("resolve at " + (Date.now() - beginTime) + " expected at " + timeline[index].begin / speedFactor)
            resolveOneTime(timeline[index].data);
            index += 1;
        }
        c.stop()
    }

    executeTimeline();
}

function Clock(updateTime, speedFactor) {
    this.timeHtml = document.getElementById("time");
    this.beginTime = Date.now()
    this.updateTime = updateTime
    this.speedFactor = speedFactor

    this.stopBool = false

    this.updateStartTime = function (t) {
        this.beginTime = t
    }

    this.start = async function () {
        if (!this.stopBool) {
            this.timeHtml.innerHTML = "Time : " + (((Date.now() - this.beginTime) / 1000) * this.speedFactor).toFixed(2) + " sec / speed factor : " + this.speedFactor
            var _this = this;
            setTimeout(function () {
                _this.start()
            }, this.updateTime * this.speedFactor)
        } else {
            this.timeHtml.innerHTML = "Finish at " + (((Date.now() - this.beginTime) / 1000) * this.speedFactor).toFixed(2) + " sec"
        }
    }
    this.stop = function () {
        this.stopBool = true
    }
}