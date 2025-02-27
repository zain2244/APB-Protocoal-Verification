var ua = navigator.userAgent.toLowerCase();
var msie = /msie/.test(ua) && !/opera/.test(ua);

function init() {
   var tbl = document.getElementsByTagName("table");
   var i, j, t, rows;
   for (i=0; i<tbl.length; ++i) {
       t = tbl[i];

       if (!/sortable/.test(t.className))
           continue;
       
       rows = t.tBodies[0].rows;
       if (rows.length < 3)
           continue;
       
       var isTreeTable = false;
       if (t.className.indexOf("treetable") != -1) {
           isTreeTable = true;
       }
       if (isTreeTable) {
           t = t.tHead.rows[0].cells;
       } else {
           t = rows[0].cells;
       }
       
       for (j=0; j<t.length; ++j) {
           var cell = t[j];

           var txt = cell.innerHTML;
           if (txt != "") {
               if (isTreeTable) {
                   cell.innerHTML = '<a href="#" class="sortheader" onclick="sortTreeTable(this);">'
                       + txt + '<span class="sortarrow">&nbsp;&nbsp;&nbsp;</span></a>';
               } else {
                   cell.innerHTML = '<a href="#" class="sortheader" onclick="s(this, false);">'
                       + txt + '<span class="sortarrow">&nbsp;&nbsp;&nbsp;</span></a>';
               }
           }
       }
   }
}

if (msie)
   window.attachEvent('onload', init);
else if (window.addEventListener)
   window.addEventListener('load', init, false);
else
   alert("Failed to add event listener");

var data;

function sort_num(a, b) {
   var da = data[a];
   var db = data[b];

   return isNaN(da) ? -1 : (isNaN(db) ? 1 : da - db);
}

function sort_str(a, b) {
   var da = data[a];
   var db = data[b];
   return da < db ? -1 : (da > db ? 1 : 0);
}

function s(a, isTreeTable) {
   var td = a.parentNode;
   var table = td.offsetParent;
   var tbody = table.tBodies[0];
   var row_n = isTreeTable ? tbody.rows.length : tbody.rows.length - 1;

   if (row_n < 2)
       return false;

   var pos = td.cellIndex;
   var span = a.lastChild;

   var raw = new Array(row_n);
   var i;
   for (i=0; i<row_n; ++i) {
       if (isTreeTable) {
           raw[i] = tbody.rows[i];
       } else {
           raw[i] = tbody.rows[i+1];
       }
   }

   switch (span.getAttribute("sortdir")) {
       case 'd':
           table.removeChild(tbody);

           span.innerHTML = '&nbsp;&nbsp;&uarr;';
           span.setAttribute('sortdir','u');
           for (i=row_n-2; i>=0; --i)
               tbody.appendChild(raw[i]);

           table.appendChild(tbody);
           return false;

       case 'u':
           table.removeChild(tbody);

           span.innerHTML = '&nbsp;&nbsp;&darr;';
           span.setAttribute('sortdir','d');
           for (i=row_n-2; i>=0; --i)
               tbody.appendChild(raw[i]);

           table.appendChild(tbody);
           return false;
   }

   var idx= new Array(row_n);
   for (i=0; i<row_n; ++i)
       idx[i] = i;

   data = new Array(row_n);
   if (td.className == "alfsrt") {
       if (msie)
           for (i=0; i<row_n; ++i)
               data[i] = raw[i].cells[pos].innerText.toLowerCase();
       else
           for (i=0; i<row_n; ++i)
               data[i] = raw[i].cells[pos].textContent.toLowerCase();

       idx.sort(sort_str);
   }
   else {
       if (msie)
           for (i=0; i<row_n; ++i)
               data[i] = parseFloat(raw[i].cells[pos].innerText);
       else
           for (i=0; i<row_n; ++i)
               data[i] = parseFloat(raw[i].cells[pos].textContent);

       idx.sort(sort_num);
   }

   if (!msie)
       table.removeChild(tbody);

   var all_span = tbody.rows[0].getElementsByTagName("span");
   for (i=0; i<all_span.length; ++i) {
       var t = all_span[i];
       switch (t.getAttribute("sortdir")) {
           case 'u':
           case 'd':
               t.innerHTML = '&nbsp;&nbsp;&nbsp;';
               t.setAttribute('sortdir', 'o');
       }
   }

   if (msie)
       table.removeChild(tbody);

   span.innerHTML = '&nbsp;&nbsp;&uarr;';
   span.setAttribute('sortdir', 'u');

   for (i=0; i<row_n; ++i)
       tbody.appendChild(raw[idx[i]]);

   table.appendChild(tbody);
   return false;
}

function sortTreeNodes(tableId, sortDir, colIndex, isAlfSort) {
   $("[data-tt-id]").each(function () {
     var nodeId = $(this).attr('data-tt-id');
       var node = $(tableId).treetable("node", nodeId);
       if (isAlfSort) {
           $(tableId).treetable("sortBranch", node, 
               function(a, b) {
                   var valA = $.trim(a.row.find("td:eq(" + colIndex + ")").text()).toUpperCase();
                   var valB = $.trim(b.row.find("td:eq(" + colIndex + ")").text()).toUpperCase();
                   if (sortDir == 'd') {
                       if (valA < valB) return -1;
                       if (valA > valB) return 1;
                   } else if (sortDir == 'u') {
                       if (valA < valB) return 1;
                       if (valA > valB) return -1;
                   }
                   return 0;
               });
       } else {
           $(tableId).treetable("sortBranch", node, 
               function(a, b) {
                   var valA = parseFloat($.trim(a.row.find("td:eq(" + colIndex + ")").text()).toUpperCase());
                   var valB = parseFloat($.trim(b.row.find("td:eq(" + colIndex + ")").text()).toUpperCase());
                   if (isNaN(valA)) {
                       valA = 0;
                   }
                   if (isNaN(valB)) {
                       valB = 0;
                   }
                   if (sortDir == 'd') {
                       if (valA < valB) return -1;
                       if (valA > valB) return 1;
                   } else if (sortDir == 'u') {
                       if (valA < valB) return 1;
                       if (valA > valB) return -1;
                   }
                   return 0;
               });
       }
   });
}

// sort the tree table
function sortTreeTable(a) {
   var td = a.parentNode;
   var pos = td.cellIndex; // cellIndex is inaccurate when colpan > 1
   var span = a.lastChild;
   var table = td.offsetParent;
   var tableId = "#" + table.getAttribute("id");
   // get the real cellIndex
   var headCells = table.tHead.rows[0].cells;
   var realCellIndex = 0;
   for (i = 0; i < pos; i++) {
       realCellIndex += headCells[i].colSpan;
   }
   pos = realCellIndex;
   switch (span.getAttribute("sortdir")) {
       case 'd':
           span.innerHTML = '&nbsp;&nbsp;&uarr;';
           span.setAttribute('sortdir','u');
           if (td.className == "alfsrt") {
               sortTreeNodes(tableId, 'd', pos, true);
           } else {
               sortTreeNodes(tableId, 'd', pos, false);
           }
           return false;
       case 'u':
           span.innerHTML = '&nbsp;&nbsp;&darr;';
           span.setAttribute('sortdir','d');
           if (td.className == "alfsrt") {
               sortTreeNodes(tableId, 'u', pos, true);
           } else {
               sortTreeNodes(tableId, 'u', pos, false);
           }
           return false;
   }
   
   var all_span = table.tHead.rows[0].getElementsByTagName("span");
   for (i  =0; i < all_span.length; ++i) {
       var t = all_span[i];
       switch (t.getAttribute("sortdir")) {
           case 'u':
           case 'd':
               t.innerHTML = '&nbsp;&nbsp;&nbsp;';
               t.setAttribute('sortdir', 'o');
       }
   }
   
   span.innerHTML = '&nbsp;&nbsp;&uarr;';
   span.setAttribute('sortdir', 'u');
}

function showContent(contendId) {
    contendId = contendId.replace("\\","\\\\");
    // contendId = contendId.replace("inst_tag_","");
    if ($("div[name='" + contendId + "']").length>0) {
        $("div[name]:not([class*='ui-layout'])").removeClass("no-filter").addClass("filter");
        $("div[name='" + contendId +"']").removeClass("filter").addClass("no-filter");
    }
    $("div[name]:first").removeClass("filter").addClass("no-filter");
    if ($("ul[name='" + contendId + "']").length>0) {
        $("ul[name]").removeClass("no-filter").addClass("filter");
        $("ul[name='" + contendId + "']").removeClass("filter").addClass("no-filter");
    } else {
        $("ul[name]").removeClass("no-filter").addClass("filter");
        $("ul[name]:first").removeClass("filter").addClass("no-filter");
    }
    // when spliting var/cross, detail pages are embeded into the summary page. We need to clear the <iframe>
    if ($("#detailFrame").length>0) {
        $("#detailFrame").attr("src", "");
    }
}

function initPage() {
    var pageURL = window.location.href;
    var anchors = pageURL.split('#');
    if (anchors.length <= 1) {
        // no anchor, get the id from the first div[title]
        var contentId = $("div[name]:first").attr("name");
        showContent(contentId);
    } else {
        var anch = anchors[anchors.length - 1];
        showContent(anch);
    }
}

function extractFileName(path) {
  var fileName = path.substring(path.lastIndexOf("/")+ 1);
  return (fileName.match(/[^.]+(\.[^?#]+)?/) || [])[0];
}

function updateDetailFrame(link) {
  var frameSrc = extractFileName(link)
  if ($("#detailFrame").length>0) {
    $("#detailFrame").attr("src", frameSrc);
  }
}
