document.addEventListener('DOMContentLoaded', function() {
  const timerElements = document.querySelectorAll('[data-started-at]');

  timerElements.forEach(function(element) {
    const startedAt = new Date(element.dataset.startedAt);
    const displayElement = element.querySelector('#elapsed-timer');

    function updateTimer() {
      const now = new Date();
      const elapsed = Math.floor(Math.abs(now - startedAt) / 1000);

      const hours = Math.floor(elapsed / 3600);
      const minutes = Math.floor((elapsed % 3600) / 60);
      const seconds = elapsed % 60;

      const hoursStr = hours == 0 ? '' : `${String(hours)}h `;
      const minutesStr = minutes == 0 ? '' : `${String(minutes)}m `;
      const secondsStr = seconds == 0 ? '' : `${String(seconds)}s`;

      if (now > startedAt) {
        displayElement.textContent = hoursStr + minutesStr + secondsStr;
      } else {
        displayElement.textContent = 'In ' + hoursStr + minutesStr + secondsStr;
      }
    }

    updateTimer();
    setInterval(updateTimer, 1000);
  });

  document.querySelectorAll('[data-href]').forEach(function(element) {
    element.addEventListener('click', function() {
      window.location.href = element.dataset.href;
    });
  });

  document.querySelectorAll('[data-open-modal]').forEach(function(element) {
    element.addEventListener('click', function() {
      const modalId = element.dataset.openModal;

      document.getElementById(modalId).setAttribute('open', '');
    });
  });

  document.querySelectorAll('[data-close-modal]').forEach(function(element) {
    element.addEventListener('click', function() {
      const modalId = element.dataset.closeModal;

      document.getElementById(modalId).removeAttribute('open');
    });
  });
});

