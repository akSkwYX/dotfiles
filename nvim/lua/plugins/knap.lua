return {
   "frabjous/knap",
   config = function ()
      local gknapsettings = {
          typoutputext = "pdf",
          typtopdf = "typst compile %docroot%",
          typtopdfviewerlaunch = "evince %outputfile%",
          typtopdfviewerrefresh = "none",
      }
      vim.g.knap_settings = gknapsettings
   end
}
