/* TWEAK DOM SELECTOR */
// (c) salt.js @https://github.com/james2doyle
"use strict";

window._s = function(selector, context, undefined) {
    var matches = {
        "#": "getElementById",
        ".": "getElementsByClassName",
        "@": "getElementsByName",
        "=": "getElementsByTagName",
        "*": "querySelectorAll"
    } [selector[0]];
    var el = (context === undefined ? document : context)[matches](selector.slice(1));
    if (el !== null) {
        return el.length < 2 ? el[0] : el;
    } else {
        return null;
    }
};

window.Element.prototype.attr = function(name, value) {
    if (value) {
        this.setAttribute(name, value);
        return this;
    } else {
        return this.getAttribute(name);
    }
};

window.Element.prototype.on = function(eventType, callback) {
    eventType = eventType.split(" ");

    for (var i = 0; i < eventType.length; i++) {
        this.addEventListener(eventType[i], callback);
    }

    return this;
};

window.NodeList.prototype.on = function(eventType, callback) {
    this.each(function(el) {
        el.on(eventType, callback);
    });
    return this;
};

window.HTMLCollection.prototype.on = function(eventType, callback) {
    Array.from(this).forEach(function(el) {
        el.on(eventType, callback);
    });
};

window.Element.prototype.hasClass = function(name) {
    return this.classList.contains(name);
}; // _s().addClass('name');


window.NodeList.prototype.addClass = function(name) {
    this.each(function(el) {
        el.classList.add(name);
    });
    return this;
};

window.Element.prototype.addClass = function(name) {
    this.classList.add(name);
    return this;
};

window.HTMLCollection.prototype.addClass = function(name) {
    Array.from(this).forEach(function(el) {
        el.classList.add(name);
    });
}; // _s().removeClass('name');


window.NodeList.prototype.removeClass = function(name) {
    this.each(function(el) {
        el.classList.remove(name);
    });
    return this;
};

window.Element.prototype.removeClass = function(name) {
    this.classList.remove(name);
    return this;
};

window.HTMLCollection.prototype.removeClass = function(name) {
    Array.from(this).forEach(function(el) {
        el.classList.remove(name);
    });
};


window.Element.prototype.fadeOut = function(name) {
    this.classList.add('fade-out');
    return this;
};


document.getCookie = function(a) {
    var b = document.cookie.match('(^|;)\\s*' + a + '\\s*=\\s*([^;]+)');
    return b ? b.pop() : '';
}

Array.prototype.remove = function() {
    var what, a = arguments,
        L = a.length,
        ax;
    while (L && this.length) {
        what = a[--L];
        while ((ax = this.indexOf(what)) !== -1) {
            this.splice(ax, 1);
        }
    }
    return this;
};


Object.defineProperty(Array.prototype, 'chunk', {
    value: function(chunkSize) {
        var R = [];
        for (var i = 0; i < this.length; i += chunkSize)
            R.push(this.slice(i, i + chunkSize));
        return R;
    }
});

function createElementFromHTML(htmlString) {
    var div = document.createElement('div');
    div.innerHTML = htmlString.trim();

    return div;
}

function validateEmail(email) {
    const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

var setNotif = function setNotif(pesan, tipe) {
    var notifikasiWrapper = document.getElementById('popup-notif');
    console.log(notifikasiWrapper);

    if (notifikasiWrapper == null) {
        console.log("no wrapper");
    }

    var raw = "\n\t<div class=\"close\">\n\t\t<button class=\"notif-close\" >x</button>\n\t</div>\n\t<div class=\"body\">\n\t\t".concat(pesan, "\n\t</div>");
    var child = createElementFromHTML(raw).addClass("popup-notif-entry").addClass(tipe);
    notifikasiWrapper.appendChild(child);
    setTimeout(function() {
        child.addClass('fade-out');
    }, 2000);
    setTimeout(function() {
        child.remove(1);
    }, 2300);
};

/* Numeric
setInputFilter(el, function (value) {
  return /^\d*\.?\d*$/.test(value);
});
*/
function setInputFilter(textbox, inputFilter) {
    ["input", "keydown", "keyup", "mousedown", "mouseup", "select", "contextmenu", "drop"].forEach(function(event) {
        textbox.addEventListener(event, function() {
            if (inputFilter(this.value)) {
                this.oldValue = this.value;
                this.oldSelectionStart = this.selectionStart;
                this.oldSelectionEnd = this.selectionEnd;
            } else if (this.hasOwnProperty("oldValue")) {
                this.value = this.oldValue;
                this.setSelectionRange(this.oldSelectionStart, this.oldSelectionEnd);
            } else {
                this.value = "";
            }
        });
    });
}


function validasiPassword(password) {
    var output = {
        success: true,
        password: password,
        kriteria: {
            minimal: true,
            mengandung_angka: true,
            mengandung_karakter_unik: true,
            mengandung_huruf_kapital: true,
        }
    };
    if (password.length < 5) {
        output.success = false;
        output.kriteria.minimal = false;
    }

    return output;
}


function randomstring(length) {
    var result = '';
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    var charactersLength = characters.length;
    for (var i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}


var fireNotif = function fireNotif(message, tipe) {
    var randomID = randomstring(5);
    var raw =
        '<notif id="notif-' +
        randomID +
        '" type="' +
        tipe +
        '">\n\t\t    <container><div class="image">\n\t\t        <i class="icon-information-outline"></i>\n\t\t    </div>\n\t\t    <div class="message">' +
        message +
        '</div>\n\t\t    <div class="action">\n\t\t        <button id="notif-btn-' +
        randomID +
        '" class="notif-btn btn notif-btn-close"><i class="icon-close"></i></button>\n\t\t    </div>\n\t\t</container></notif>';
    document.body.innerHTML += raw;

    setTimeout(function() {
        var rootEl = document.getElementById('notif-' + randomID);
        if (rootEl !== null) {
            rootEl.remove();
        }
    }, 1500);

    var notifBtnClose = document.querySelectorAll(".notif-btn-close");
    Array.from(notifBtnClose).forEach(function(el) {
        el.onclick = function(e) {
            e.preventDefault();
            var rootEl = document.getElementById('notif-' + randomID);
            if (rootEl !== null) {
                rootEl.remove();
            }
            setTimeout(function() {
                var rootEl = document.getElementById('notif-' + randomID);
                if (rootEl !== null) {
                    rootEl.remove();
                }
            }, 500);
            console.log(e);
        };
    });
};