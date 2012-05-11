var stepClass = function(current, idx, def) {
  def = def || 'span2';
  var match = $.isArray(idx) ? idx.indexOf(current) > -1 : idx == current;
  var max = $.isArray(idx) ? idx[idx.length - 1] : idx;
  return (match ? 'current ' : current > max ? 'done ' : '') + def;
}

var NewRegistration = function() {
  var self = this,
      pages = [ 'eligibility', 'identity', 'address', 'options', 'confirm', 'oath', 'download', 'congratulations' ];

  // Navigation
  self.currentPageIdx = ko.observable(0);
  self.page = ko.computed(function() { return pages[self.currentPageIdx()]; }, self);
  self.prevPage = function() { self.currentPageIdx(self.currentPageIdx() - 1); }
  self.nextPage = function() { self.currentPageIdx((self.currentPageIdx() + 1) % pages.length); }
}

ko.applyBindings(new NewRegistration());
