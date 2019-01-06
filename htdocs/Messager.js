class NickMessager {
    constructor() {
        let loc = document.location;
        let host = loc.hostname;

        var watchers = this.watchers = {};
        var on_message = msg => {
            let parts = msg.data.split('\t');
            let type = parts.shift();
            let event = parts.shift();
            if (
                watchers.hasOwnProperty( type )
                &&
                watchers[type].hasOwnProperty( event )
            ) {
                watchers[type][event].apply( null, parts );
            }
        };

        if ( !! window.EventSource ) {
            new EventSource(
                `${loc.protocol}//${host}${NICK_MESSAGER_PATH}`
            ).addEventListener(
                'message', on_message, false
            );
        } else if ( !! window.WebSocket ) {
            new WebSocket(
                `ws://${host}:${NICK_MESSAGER_PORT}/`,
                [ 'chat' ]
            ).onmessage = on_message;
        } else {
            throw 'No browser messager support'
        }
    }

    add_watcher( type ) {
        let events = {};
        this.watchers[type] = events;
        return events;
    }
}
