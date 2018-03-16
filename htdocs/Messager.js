function NickMessager(filter, callback) {
    var flt_len = filter.length;
    var events = {};
    var parts;
    var host = document.location.hostname;
    var handler = function(msg) {
        if (
            msg.data.substr(0, flt_len) === filter
        ) {
            parts = msg.data.substr(flt_len + 1).split('\t');
            if ( parts[0] in events ) {
                events[ parts.shift() ].apply( this, parts );
            }
        }
    };
    if (!! window.EventSource) {
        var es = new EventSource(
            location.protocol === 'https:'
            ? 'https://' + host + NICK_MESSAGER_PATH
            : 'http://' + host + ':' + NICK_MESSAGER_PORT + '/'
        );
        es.addEventListener(
            'message', handler, false
        );
    } else if (!! window.WebSocket) {
        var ws = new WebSocket(
            'ws://' + host + ':' + NICK_MESSAGER_PORT + '/',
            [ 'chat' ]
        );
        ws.onmessage = handler;
    } else {
        throw 'No browser messager support'
    }
    return events;
}
