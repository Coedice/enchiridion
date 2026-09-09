(function () {
  var STORAGE_TRANSLATION = 'selectedTranslation';
  var STORAGE_ROMAN = 'useRomanNumerals';
  var DEFAULT_TRANSLATION = 'William Abbott Oldfather';

  function getTranslation() {
    try {
      return localStorage.getItem(STORAGE_TRANSLATION) || DEFAULT_TRANSLATION;
    } catch (e) {
      return DEFAULT_TRANSLATION;
    }
  }

  function getRoman() {
    try {
      return localStorage.getItem(STORAGE_ROMAN) === 'true';
    } catch (e) {
      return false;
    }
  }

  function setRoman(value) {
    try {
      localStorage.setItem(STORAGE_ROMAN, value ? 'true' : 'false');
    } catch (e) {}
  }

  function romanize(number) {
    var romanNumbers = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
    var romanValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    var romanized = '';
    for (var i = 0; i < romanValues.length; i++) {
      while (number >= romanValues[i]) {
        number -= romanValues[i];
        romanized += romanNumbers[i];
      }
    }
    return romanized;
  }

  function applyNumerals() {
    var useRoman = getRoman();
    document.querySelectorAll('.chapter-number').forEach(function (el) {
      var n = parseInt(el.getAttribute('data-num'), 10);
      if (!n) return;
      el.textContent = useRoman ? romanize(n) : String(n);
    });
  }

  var translationPromise = null;

  function loadTranslations() {
    if (translationPromise) return translationPromise;
    translationPromise = fetch(document.querySelector('meta[name="translations-url"]').content)
      .then(function (r) { return r.json(); })
      .catch(function () { return []; });
    return translationPromise;
  }

  function applyContent() {
    loadTranslations().then(function (data) {
      var selected = getTranslation();
      var translation = data.filter(function (t) { return t.title === selected; })[0] || data[0];
      if (!translation) return;
      var texts = translation.chapters || [];
      document.querySelectorAll('.chapter').forEach(function (sec) {
        var idx = parseInt(sec.getAttribute('data-index'), 10);
        var textEl = sec.querySelector('.text');
        if (textEl && texts[idx] != null) {
          textEl.textContent = texts[idx];
        }
      });
      if (window.location.hash) {
        var target = document.querySelector(window.location.hash);
        if (target) target.scrollIntoView();
      }
    });
  }

  function initSettings(translations) {
    var select = document.getElementById('translation-select');
    var sourceBtn = document.getElementById('translation-source');
    var romanToggle = document.getElementById('roman-toggle');
    var devBtn = document.getElementById('dev-website');

    if (select) {
      translations.forEach(function (t) {
        var opt = document.createElement('option');
        opt.value = t.title;
        opt.textContent = t.title;
        select.appendChild(opt);
      });
      select.value = getTranslation();
      select.addEventListener('change', function () {
        try {
          localStorage.setItem(STORAGE_TRANSLATION, select.value);
        } catch (e) {}
        var url = translations.filter(function (t) { return t.title === select.value; })[0];
        if (sourceBtn) sourceBtn.dataset.url = url ? url.url : '';
      });
    }

    if (sourceBtn) {
      var current = translations.filter(function (t) { return t.title === getTranslation(); })[0];
      sourceBtn.dataset.url = current ? current.url : '';
      sourceBtn.addEventListener('click', function () {
        if (sourceBtn.dataset.url) window.open(sourceBtn.dataset.url, '_blank');
      });
    }

    if (romanToggle) {
      romanToggle.checked = getRoman();
      romanToggle.addEventListener('change', function () {
        setRoman(romanToggle.checked);
      });
    }

    if (devBtn) {
      devBtn.addEventListener('click', function () {
        window.open('https://github.com/Coedice/enchiridion', '_blank');
      });
    }
  }

  function init() {
    applyNumerals();
    loadTranslations().then(function (data) {
      if (document.getElementById('content-page')) {
        applyContent();
      }
      if (document.getElementById('translation-select')) {
        initSettings(data);
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
