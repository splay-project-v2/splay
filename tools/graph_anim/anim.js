var stopClock = false

function graph() {
    const sleep = (milliseconds) => {
        return new Promise(resolve => setTimeout(resolve, milliseconds))
    }
    
    const timeline = [
        {begin: 500, end: 25000, data: { type: "addNode", label:"Splayd 1", id: 1}},
        {begin: 1550, end: 32500, data: { type: "addNode", label:"Splayd 2", id: 2}},
        {begin: 1560, end: 35000, data: { type: "addNode", label:"Splayd 3", id: 3}},
        {begin: 1560, end: 35000, data: { type: "addNode", label:"Splayd 4", id: 4}},
        {begin: 1560, end: 35000, data: { type: "addNode", label:"Splayd 5", id: 5}},

    
        {begin: 1600, end: 15000, data: { type: "addEdge", to: 1, from: 2}},
        {begin: 1600, end: 15000, data: { type: "addEdge", to: 2, from: 1}},

        {begin: 1600, end: 15000, data: { type: "addEdge", to: 1, from: 4}},
        {begin: 1600, end: 15000, data: { type: "addEdge", to: 4, from: 1}},
        {begin: 1850, end: 15000, data: { type: "addEdge", to: 2, from: 3}},
        {begin: 1850, end: 15000, data: { type: "addEdge", to: 5, from: 3}},
        {begin: 1850, end: 15000, data: { type: "addEdge", to: 5, from: 1}},
        {begin: 1850, end: 15000, data: { type: "addEdge", to: 5, from: 2}},
        {begin: 1850, end: 15000, data: { type: "addEdge", to: 5, from: 4}},
        {begin: 1850, end: 15000, data: { type: "addEdge", to: 4, from: 5}},
        {begin: 1850, end: 15000, data: { type: "addEdge", to: 2, from: 5}},

        {begin: 1855, end: 15000, data: { type: "addEdge", to: 3, from: 2}},
        {begin: 1855, end: 15000, data: { type: "addEdge", to: 3, from: 5}},
        {begin: 2515, end: 15000, data: { type: "addEdge", to: 1, from: 3}},
        {begin: 2519, end: 15000, data: { type: "addEdge", to: 3, from: 1}},


        {begin: 2515, end: 15000, data: { type: "addEdge", to: 4, from: 3}},
        {begin: 2519, end: 15000, data: { type: "addEdge", to: 3, from: 4}},

        {begin: 5530, end: 5620, data: { type: "packet", to: 2, from: 3, color:"#000000"}},
        {begin: 5540, end: 5550, data: { type: "packet", to: 3, from: 2, color:"#000000"}},
        {begin: 5550, end: 5560, data: { type: "packet", to: 1, from: 3, color:"#000000"}},

    ];
    
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
        maxVelocity:10,
        solver: 'repulsion',
        repulsion: {
            centralGravity: 0.5,
            springConstant: 0.01,
            nodeDistance: 150
        }
       }
    };
    var network = new vis.Network(container, data, options);
    
    function resolveOneTime(timedata, during) {
        if (timedata.type == "addNode") {
            const idNode = counterNode;
            nodes.add({id: idNode, label: timedata.label, borderWidth:3, font:{size:20}})
    
            counterNode += 1;
            setTimeout(function(){ 
                nodes.remove(idNode)
            }, during);
        } else if (timedata.type == "addEdge") {
            const idEdge = "" + timedata.to +"-"+timedata.from
            edges.add({
                to: timedata.to, 
                from: timedata.from, 
                arrows:"to", width: 2, 
                id: idEdge, length:300,
               // smooth: false

            })
            
            setTimeout(function(){ 
                edges.remove(idEdge)
            }, during);

        } else if (timedata.type == "packet") {
            const idEdge = "" + timedata.to +"-"+timedata.from
            
            edges.update([{ width: 4, id: idEdge, color: {
                color: timedata.color,
                highlight: timedata.color,
                hover: timedata.color,
                inherit: false,
                opacity: 1.0
            }}])

            setTimeout(function(){ 
                edges.update([{ width: 2, id: idEdge, color: '#848484'}])
            }, during);
        }
    }
    
    const executeTimeline = async () => {
       
        var date = new Date();
        var beginTime = date.getTime();
        startTime(beginTime)
        index = 0;
        while (timeline.length > index) {
            var timestamp = Date.now();
            timeToWait = timeline[index].begin - (timestamp - beginTime);
            if (timeToWait >= 0){
                await sleep(timeToWait);
            }
            console.log("resolve at " + (Date.now() - beginTime) + " expected at " + timeline[index].begin)
            resolveOneTime(timeline[index].data, timeline[index].end - timeline[index].begin);
            index += 1;
        }
    }
    
    executeTimeline();
}

function startTime(beginTime) {
    var timeHtml = document.getElementById("time");

    function clock(){
        if (!stopClock) {
            timeHtml.innerHTML = "Time : " + Math.floor ((Date.now() - beginTime) / 1000 )+ " sec"
            setTimeout(clock, 500)
        } else {
            timeHtml.innerHTML = "Finish after " + Math.floor ((Date.now() - beginTime) / 1000 ) + " sec"
        }
    }
    clock()
}