var websocket;
var shell;
var last_prompt = null;
var color = {
  black:   "\x1b[1;30m",
  red:     "\x1b[1;31m",
  green:   "\x1b[1;32m",
  yellow:  "\x1b[1;33m",
  blue:    "\x1b[1;34m",
  magenta: "\x1b[1;35m",
  cyan:    "\x1b[1;36m",
  white:   "\x1b[1;37m",
  reset:   "\x1b[0m"
};

var greetings_message = "" +
color.magenta + "         .'.          " + color.reset + color.white + "  oooooooooooo oooo   o8o               o8o          \n" + color.reset + 
color.magenta + "       ,xOc:          " + color.reset + color.white + "  `888'     `8 `888   `\"'               `\"'          \n" + color.reset + 
color.magenta + "      l0KKxd.         " + color.reset + color.white + "   888          888  oooo  oooo    ooo oooo  oooo d8b\n" + color.reset + 
color.magenta + "     cO0KK0x;         " + color.reset + color.white + "   888oooo8     888  `888   `88b..8P'  `888  `888\"\"8P\n" + color.reset + 
color.magenta + "   .:kO000KOl,.       " + color.reset + color.white + "   888    \"     888   888     Y888'     888   888    \n" + color.reset + 
color.magenta + "  .'kkkO00OkOko'      " + color.reset + color.white + "   888       o  888   888   .o8\"'88b    888   888    \n" + color.reset + 
color.magenta + " ';cKOxOOOkxkkkx:.    " + color.reset + color.white + "  o888ooooood8 o888o o888o o88'   888o o888o d888b   \n" + color.reset + 
color.magenta + ".c:d00OkOxxddxxxddo'  \n" + color.reset +
color.magenta + ":lcdOOO0xdolooddodxxo." + color.reset + "   ooooo   oooooo     oooo            .o8           .oooooo..o oooo                  oooo  oooo  \n" + color.reset +
color.magenta + "llldxkOOOxlcloodddxxx:" + color.reset + "   `888.    `888.     .8'            \"888          d8P'    `Y8 `888                  `888  `888 \n" + color.reset +
color.magenta + "coodddkOOkkxdddxddddd," + color.reset + "    `888.   .8888.   .8'    .ooooo.   888oooo.     Y88bo.       888 .oo.    .ooooo.   888   888 \n" + color.reset +
color.magenta + ".::clllcldxxxddol:::, " + color.reset + "     `888  .8'`888. .8'    d88' `88b  d88' `88b     `\"Y8888o.   888P\"Y88b  d88' `88b  888   888 \n" + color.reset +
color.magenta + " .;:;:;,,,;cccll:;;.  " + color.reset + "      `888.8'  `888.8'     888ooo888  888   888         `\"Y88b  888   888  888ooo888  888   888 \n" + color.reset +
color.magenta + "   ..,;'..'',,''..    " + color.reset + "       `888'    `888'      888    .o  888   888    oo     .d8P  888   888  888    .o  888   888 \n" + color.reset +
color.magenta + "      .......         " + color.reset + "        `8'      `8'       `Y8bod8P'  `Y8bod8P'    8\"\"88888P'  o888o o888o `Y8bod8P' o888o o888o\n\n" + color.reset +
"https://github.com/glejeune/ews\n\n\n"

$(document).ready(init);

function send(data) {
  shell.pause();
  if(websocket.readyState == websocket.OPEN){
    json = {"command":data, "uuid":readCookie("ews")};
    websocket.send(JSON.stringify(json));
  } else {
    shell.error('not connected!');
  }
}

function init() {
  shell = $('body').terminal(function(command, term) {
    send(command);
  }, {
    greetings: greetings_message,
    clear: false,
    exit: false
  });

  start_ws();
}

function start_ws() {
  shell.pause();

  if(!("WebSocket" in window)) {
    shell.error("** websockets are not supported!")
  } else {
    host = "ws://" + http_host + ":" + http_port + "/websocket";
    websocket = new WebSocket(host);
    websocket.onopen = function(e) { ws_onopen(e) };
    websocket.onclose = function(e) { ws_onclose(e) };
    websocket.onmessage = function(e) { ws_onmessage(e) };
    websocket.onerror = function(e) { ws_onerror(e) };
  }
}

function ws_onopen(e) {
  // shell.echo(color.white + "connected" + color.reset);
}

function ws_onclose(e) {
  shell.echo(color.white + "disconnected" + color.reset);
}

function ws_onmessage(e) {
  try {
    obj = JSON && JSON.parse(e.data) || $.parseJSON(e.data) || nil;
    displayResponse(obj);
  } catch(err) {
    shell.error("** Invalide server response : " + e.data); 
    if(last_prompt) {
      shell.set_prompt(last_prompt);
    }
  }
}

function displayResponse(obj) {
  if(obj.hello) {
    shell.echo(color.green + obj.hello + color.reset);
  }

  if(obj.result) {
    shell.echo(color.yellow + obj.result + color.reset);
  }

  if(obj.info) {
    shell.echo(color.white + obj.info + color.reset);
  }

  if(obj.error) {
    shell.echo(color.red + obj.error + color.reset);
  }

  if(obj.uuid) {
    shell.echo(color.green + "== open session : " + obj.uuid + color.reset);
    eraseCookie("ews");
    createCookie("ews", obj.uuid, 1);
  }

  if(obj.prompt) {
    last_prompt = obj.prompt;
    shell.set_prompt(last_prompt);
  }

  shell.resume();
}
