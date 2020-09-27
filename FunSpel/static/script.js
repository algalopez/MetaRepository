const STATE_LOADING = "loading"
const STATE_INTERACTIVE = "interactive"
const STATE_COMPLETE = "complete"

if (document.readyState == STATE_LOADING) {
    document.addEventListener('DOMContentLoaded', start);
} else {
    start();
}

function start() {
    document.getElementById("intro").addEventListener("click", function(){load_page('01_Intro.html')});
    document.getElementById("currying").addEventListener("click", function(){load_page('02_Currying.html')});
    document.getElementById("recursion").addEventListener("click", function(){load_page('03_Recursion.html')});
    document.getElementById("composition").addEventListener("click", function(){load_page('04_Composition.html')});
    document.getElementById("monads").addEventListener("click", function(){load_page('05_Monads.html')});
    document.getElementById("hof").addEventListener("click", function(){load_page('06_HOF.html')});
    document.getElementById("lenses").addEventListener("click", function(){load_page('07_Lenses.html')});
    document.getElementById("lambdaCalculus").addEventListener("click", function(){load_page('08_LambdaCalculus.html')});
    document.getElementById("bibliography").addEventListener("click", function(){load_page('09_Bibliography.html')});
 }

function load_page(page) {
    console.log("Loading page" + page);
    document.getElementById('iframe').src = "static/"+page;
}

