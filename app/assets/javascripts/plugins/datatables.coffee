#= require datatables/jquery.dataTables
#= require datatables/dataTables.bootstrap4
#= require datatables/extensions/Responsive/dataTables.responsive
#= require datatables/extensions/Responsive/responsive.bootstrap4
#= require datatables/extensions/Buttons/dataTables.buttons
#= require datatables/extensions/Buttons/buttons.html5
#= require datatables/extensions/Buttons/buttons.print
#= require datatables/extensions/Buttons/buttons.colVis
#= require datatables/extensions/Buttons/buttons.bootstrap4
#= require datatables/extensions/Select/dataTables.select
#= require datatables/extensions/RowReorder/dataTables.rowReorder
#= require datatables/extensions/FixedHeader/dataTables.fixedHeader
#= require datatables/extensions/FixedColumns/dataTables.fixedColumns
#= require datatables/extensions/KeyTable/dataTables.keyTable
#= require datatables/extensions/RowGroup/dataTables.rowGroup
# require dataTables.rowsGroup
#= require datatables/plugins/api/sum
# require datatables/plugins/pagination/input
# require datatables/plugins/search/alphabetSearch

@App or (@App = {})

#$.fn.dataTable.ext.errMode = 'throw';

$.fn.dataTable.ext.buttons.export =
  extend: 'collection'
  text: '<i class="mi" data-toggle="tooltip" data-placement="top" title="Export" data-feather="move_to_inbox"></i>'
  className: "btn-fab no-caret export"
  autoClose: true
  collectionLayout: 'fixed three-column'
  buttons: ["copyHtml5", "csvHtml5", "print"]

$.extend $.fn.dataTable.ext.buttons.copyHtml5,
  text: '<i class="mi">content_copy</i> <span> Copy </span>'
  exportOptions:
    columns: [':visible:not(.skip-export)']

$.extend $.fn.dataTable.ext.buttons.csvHtml5,
  text: '<i class="mi">description</i> <span> CSV </span>'
  exportOptions:
    stripNewlines: false
    columns: [':visible:not(.skip-export)']

$.extend $.fn.dataTable.ext.buttons.print,
  text: '<i class="mi">print</i> <span> Print </span>'
  exportOptions: 
    columns: [':visible:not(.skip-export)']
  customize: (win) ->
    image_url = window.location.origin+'/print.png'
    $(win.document.documentElement).css('background', '#fff')
    $(win.document.body).css('padding-top', '50px')
    $(win.document.body).css('background', '#fff')
    $(win.document.body).css('font-size', '14px').prepend "<img src='" + image_url + "' style='position:absolute; top:0; left:0; rigth: 0; background-size: cover; height: 50px;' />"
    $(win.document.body).find('table').addClass('compact').css 'font-size', 'inherit'

$.fn.dataTable.ext.buttons.reorder =
  text: '<i class="" data-column="reorder-control" data-toggle="tooltip" data-placement="top" title="Reorder" data-feather="corner-down-right"></i>'
  className: "toggle-vis"
  titleAttr: 'Reorder'

$.fn.dataTable.ext.buttons.checkboxes =
  text: '<i class="mi" data-column="select-control" data-toggle="tooltip" data-placement="top" title="Select" data-feather="check-square"></i>'
  className: "toggle-vis"
  titleAttr: 'Checkbox'

$.fn.dataTable.ext.buttons.filterer =
  text: '<i class="mi" data-toggle="tooltip" data-placement="top" data-feather="filter" title="Filter"></i>'
  className: ""
  action: (e, dt, node, config) ->
    $('#modal-filter').modal('show')

$.fn.dataTable.ext.buttons.reload =
  text: '<i class="" data-toggle="tooltip" data-feather="refresh-ccw" data-placement="top" title="Reload"></i>'
  className: ""
  action: (e, dt, node, config) ->
    dt.ajax.reload()

$.fn.dataTable.ext.buttons.addNew =
  text: '<i class="" data-toggle="tooltip" data-feather="plus-square" data-placement="top" title="Add New"></i>'
  className: ""
  action: (e, dt, node, config) ->
    table_id = "#" + dt.table().node().id
    url = $(table_id).data('new')
    if $(table_id).data('new-ajax') == 'true'
      $.get(url, {}, null, "script")
    else
      window.location = url

$.fn.dataTable.ext.buttons.records =
  text: '<i class="mi" data-toggle="tooltip" data-placement="top" title="Switch to Record View">view_comfy</i>'
  className: "btn-fab records"
  action: (e, dt, node, config) ->
    table_id = "#" + dt.table().node().id
    url = $(table_id).data('source-records') + "?display=records"
    $.get(url, {}, null, "script")

$.fn.dataTable.ext.buttons.hosts =
  text: '<i class="mi" data-toggle="tooltip" data-placement="top" title="Switch to Hosts View">view_compact</i>'
  className: "btn-fab hosts"
  action: (e, dt, node, config) ->
    table_id = "#" + dt.table().node().id
    url = $(table_id).data('source-hosts')
    console.log "URL: " + url
    $.get(url, {}, null, "script")

$.extend true, $.fn.dataTable.Buttons.defaults,
  dom:
    container:
      className: 'dt-buttons btn-group btn-group-sm btn-group-fluid pt-2'
    button:
      className: 'btn btn-light hover:bg-blue-400 hover:text-white border'

$.extend $.fn.dataTable.ext.classes,
  sWrapper:      "dataTables_wrapper dataTables-container dt-bootstrap4"
  sFilterInput:  "searchfield"
  sProcessing:   "dataTables_processing"

$.fn.dataTable.Api.register 'ReOrder', (url)->
  dttb = this
  dttb.on 'row-reorder', (e, diff, edit) ->
    data = undefined
    i = 0
    ien = diff.length
    while i < ien
      row = dttb.row(diff[i].node).data()
      if row.id == edit.triggerRow.data().id
        data =
          id: row.id
          old: diff[i].oldPosition
          new: diff[i].newPosition
        $.post url, data
      i++


$.fn.dataTable.Api.register 'MultipleDelete', (url)->
  dttb = this
  $(document).on 'click', 'a.delete-selected', (e) ->
    selected_rows = dttb.rows(selected: true)
    selected_rows_ids = $.map(selected_rows.data(), (data) -> data['id'])
    if selected_rows.count() > 0
      proceed = ->
        url = url
        data = 
          _method: 'DELETE'
          ids: selected_rows_ids
        $.post(url, data).done (data) ->
          dttb.columns.adjust().draw(false)
          
    msg = 'Are you sure you want to delete the ' + selected_rows.count() + ' record(s).'
    #alertify.confirm 'Notice', msg, proceed, null
    swal(
      title: 'Are you sure?'
      text: msg
      type: 'warning'
      showCancelButton: true
      confirmButtonText: 'Yes, delete it!'
      closeOnConfirm: false).then (isConfirm) ->
      if isConfirm
        proceed()
        swal 'Deleted!', 'Your file has been deleted.', 'success'
      return

$.fn.dataTable.Api.register 'MultipleEdit', (url)->
  dttb = this
  $(document).on 'click', 'a.edit-selected', (e) ->
    selected_rows = dttb.rows(selected: true)
    selected_rows_ids = $.map(selected_rows.data(), (data) -> data['id'])
    if selected_rows.count() > 0
      $.ajax
        dataType: 'script'
        method: 'POST'
        url: url
        data:
          ids: selected_rows_ids
          multiple: true
        success: (msg) ->
          console.log msg
          return
  
#datatable
$.extend $.fn.dataTable.defaults,
  #responsive: true
  responsive:
      details: { type: 'column', target: '.control' }
  pagingType: 'full'
  autoWidth: false
  stateSave: false
  searchDelay: 1000
  #select: true
  rowReorder: {dataSrc: 'position', selector: '.handle' },
  rowGroup: {enable: false}
  select: { style: 'multi', selector: '.select-checkbox', info: false },
  language:
    emptyTable: "<div class='text-center p-1 spacious clean' style='color: #9E9E9E; font-weight: 200;'>
            <p class='small'>Kosong</p></div>"

    info:       "_START_ - _END_ daripada _TOTAL_ "
    lengthMenu: "Rekod setiap halaman:     _MENU_ "
    infoFiltered: ""
    infoEmpty:  ""
    paginate:
      previous: "<i class='' data-feather='arrow-left'></i>"
      next:     "<i class='' data-feather='arrow-right'></i>"
      first:    "<i class='' data-feather='chevrons-left'></i>"
      last:     "<i class='' data-feather='chevrons-right'></i>"
    search: ""
    select:
      rows:
        _: ", %d rows selected"
        0: ""
        1: ", %d row selected"
    loadingRecords: "<div class='spin-kit'>
                        <div class='bounce1'></div>
                        <div class='bounce2'></div>
                        <div class='bounce3'></div>
                    </div>"
    processing: "<div class='progress-circular'>
                  <div class='progress-circular-wrapper'>
                    <div class='progress-circular-inner'>
                      <div class='progress-circular-left'>
                        <div class='progress-circular-spinner'></div>
                      </div>
                      <div class='progress-circular-gap'></div>
                      <div class='progress-circular-right'>
                        <div class='progress-circular-spinner'></div>
                      </div>
                    </div>
                  </div>
                </div>"
  buttons: ["reload", "checkboxes", "reorder", "filterer", "addNew"]

  dom:
    "<'row table-toolbar px-2'f<'title left-action text-left'><'ml-auto right-action text-right'<'buttons'B> <'select-info'> >>" +
    "<'row'<'dttb col-12 px-0'tr>>" +
    "<'row'<'col-sm-12 table-footer'lip>>"
        
  preDrawCallback: (settings)->
    api = new $.fn.dataTable.Api(settings)
    feather.replace();
    $(".dataTables_filter label").addClass("searchbox")
    pagination = $(this).closest('.dataTables_wrapper').find('.dataTables_paginate')
    head = $(this).closest('.dataTables_wrapper').find('thead.hidden-empty')
    dt_length = $(this).closest('.dataTables_wrapper').find('dataTables_length')
    if api.page.info().pages <= 1
      pagination.hide()
      dt_length.hide()
    else
      pagination.show()
      dt_length.show()

    if (! api.data().count())
      head.hide()
    else
      head.show()

  drawCallback: (settings)->
    api = new $.fn.dataTable.Api($(this))
    table_id = "#" + api.table().node().id
    table_wrapper = table_id + "_wrapper"
    selected_rows = api.rows(selected: true).count()
    show_buttons(table_wrapper, selected_rows, table_id)
    api.on 'select deselect', (e, dt, type, indexes) ->
      selected_rows = api.rows(selected: true).count()
      show_buttons(table_wrapper, selected_rows, table_id)
    #api.tables( {visible: true, api: true} ).columns.adjust().fixedColumns().relayout();
    col = $(table_id).data('rowgroup')
    if col
      api.rowGroup().enable()
      api.rowGroup().dataSrc(col)

    $('time').timeago()
    $('[data-toggle="tooltip"]').tooltip()
    feather.replace();

  initComplete: (settings)->
    api = new $.fn.dataTable.Api($(this))
    table_id = "#" + api.table().node().id
    # $('.top-tabs').tabdrop('layout')
    feather.replace();
    $('button.toggle-vis').on 'click', (e) ->
      e.preventDefault()
      col = $(this).find('.mi').data('column')
      col_class = "."+col
      column = api.column(col_class)
      column.visible !column.visible()
      api.columns.adjust().draw(false)

      if (col == "select-control")
        console.log(table_id + " #checkbox-select-all")
        $(table_id + " #checkbox-select-all")[0].checked = false
        checkedBox(table_id, api)
      

checkedBox = (table_id, dttb) ->
  console.log("id " + table_id)
  #select all checkboxes
  $(table_id + " #checkbox-select-all").change ->
    #"select all" change 
    # console.log 'change checked all'
    status = this.checked

    dttb.rows({search: 'applied'}).every ->
      read_only = @data().noselect
      # console.log("read " + read_only)
      element = @node()
      checkbox = $(element).find('.checkbox')
      if read_only == undefined
        checkbox[0].checked = status
        if status
          @select()
        else
          @deselect()
      return
    return

  $(table_id + ' .checkbox').change ->
    #".checkbox" change 
    #uncheck "select all", if one of the listed checkbox item is unchecked
    console.log("masuk sini abe")
    if this.checked == false
      #if this item is unchecked
      $(table_id + " #checkbox-select-all")[0].checked = false
      #change "select all" checked status to false
      # dttb.rows().deselect();
    #check "select all" if all checkbox items are checked
    console.log($(table_id + ' .checkbox:checked').length == $(table_id + ' .checkbox').not(':disabled').length)
    if $(table_id + ' .checkbox:checked').length == $(table_id + ' .checkbox').not(':disabled').length
      #console.log("masuk sini check it out")
      $(table_id + " #checkbox-select-all")[0].checked = true
    

show_buttons = (table_wrapper, rows, table_id)-> 
  # console.log("row selected : " + rows)
  if rows == 0
    $(table_wrapper + ' .select-info').html('').hide()
    $(table_wrapper + ' .buttons').show()
  else
    btn = ""
    if $(table_id).data('delete')
      btn += "<div class='dt-buttons btn-group btn-group-sm btn-group-fluid'><a class='delete-selected btn btn-light btn-fab' data-turbolinks='false'> <i class='mi'>delete</i></a></div>"  
    if $(table_id).data('edit')
      btn += "<div class='dt-buttons btn-group btn-group-sm btn-group-fluid'><a class='edit-selected btn btn-light btn-fab' data-turbolinks='false'> <i class='mi'>edit</i></a></div>"
    $(table_wrapper + ' .select-info').html("<span class='chip'>" + rows + " record(s) selected </span>" + btn).show()
    $(table_wrapper + ' .buttons').hide()

$(document).on 'preInit.dt', (e, settings) ->
  api = new ($.fn.dataTable.Api)(settings)
  table_id = "#" + api.table().node().id
  url = $(table_id).data('source')
  api.ajax.url url
  feather.replace();
  title = $(table_id).data('title')
  $(table_id + "_wrapper" + " .left-action").prepend(title) if title

  api.buttons('.addnew').disable()
  url = $(table_id).data('new')
  if url
    api.buttons('.addnew').enable()

  api.buttons('.filterer').disable()
  url = $(table_id).data('filterer')
  if url
    api.buttons('.filterer').enable()
  
  api.buttons('.reorder').disable()
  url = $(table_id).data('reorder')
  if url
    api.ReOrder(url) 
    api.buttons('.reorder').enable()

  api.buttons('.selector').disable()
  url = $(table_id).data('delete')
  if url
    api.MultipleDelete(url) 
    api.buttons('.selector').enable()

  url = $(table_id).data('edit')
  if url
    api.MultipleEdit(url)
    api.buttons('.selector').enable()


  url = $(table_id).data('show')
  if url
    $(table_id).on 'click', "td:not(.action)", (e) ->
      row = api.row(this)
      if row.data()
        path = row.data()[url]
        if url == "show_url"
          Turbolinks.visit path 
        else
          $.get(path, {}, null, "script") 

App.initDatatable = ->
  $("table#dttb").DataTable() unless $.fn.DataTable.isDataTable("table#dttb")
  $("table[id^=dttb-]").DataTable()

  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    $.fn.dataTable.tables(
      visible: true
      api: true).columns.adjust()


$(document).on 'turbolinks:before-cache', ->
  dataTable =  $($.fn.dataTable.tables(true)).DataTable()
  feather.replace();
  if (dataTable != null)
   dataTable.destroy();
   dataTable = null;

