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
            let url = `${loc.protocol}//${host}:${NICK_MESSAGER_PORT}/`;
            let open_event_source = () => {
                let evt = new EventSource( url );
                evt.onopen = () => {
                    console.log( 'NickMessager EventSource: ' + url );
                };
                evt.onerror = error => {
                    console.error( `NickMessager EventSource ${url} error: `, error );
                }
                evt.addEventListener( 'message', on_message, false );
            };
            let check_url = ( reject ) => {
                let xhr = new XMLHttpRequest();
                xhr.open( 'head', url );
                xhr.onload = open_event_source;
                xhr.onerror = reject;
                xhr.send();
            };
            check_url( () => {
                console.error( `EventSource port ${NICK_MESSAGER_PORT} not available` );
                url = `${loc.protocol}//${host}${NICK_MESSAGER_PATH}`;
                check_url( () => {
                    throw `EventSource path ${NICK_MESSAGER_PATH} not available`;
                }
                );
            } );
        } else if ( !! window.WebSocket ) {
            let url = `ws://${host}:${NICK_MESSAGER_PORT}/`;
            let ws = new WebSocket( url, [ 'chat' ] );
            ws.onopen = () => {
                console.log( 'NickMessager WebSocket: ' + url );
            };
            ws.onerror = error => {
                console.error( `NickMessager WebSocket ${url} error: `, error );
            }
            ws.onmessage = on_message;
        } else {
            throw 'No browser messager support';
        }
    }

    add_watcher( type ) {
        let events = {};
        this.watchers[type] = events;
        return events;
    }
}
