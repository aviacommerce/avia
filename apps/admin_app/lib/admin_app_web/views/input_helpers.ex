defmodule AdminAppWeb.InputHelpers do
  @moduledoc """
  Form helpers to generate form elements like input, checkbox, select(with select2)
  """
  use Phoenix.HTML
  alias AdminAppWeb.ErrorHelpers, as: EH
  alias Phoenix.HTML.Form

  def input(form, field, name \\ nil, opts \\ []) do
    validate_required =
      form
      |> input_validations(field)
      |> check_required

    type = Form.input_type(form, field)
    field_name = name || field
    label_opts = [class: "label #{validate_required}"]
    input_opts = [class: "form-control #{state_class(form, field)}"] ++ opts

    case is_horizontal_layout?(opts) do
      true -> make_horizontal_input(form, field, field_name, type, input_opts, label_opts, opts)
      _ -> make_vertical_input(form, field, field_name, type, input_opts, label_opts, opts)
    end
  end

  defp make_horizontal_input(form, field, field_name, type, input_opts, label_opts, opts) do
    [
      content_tag :label, class: "col-sm-3 col-form-label" do
        [
          content_tag :div, label_opts do
            [humanize(field_name)]
          end
        ] ++ add_description(get_description(opts))
      end,
      content_tag :div, class: "col-sm-9" do
        [
          content_tag :div, class: "form-group" do
            [apply(Form, type, [form, field, input_opts]), EH.error_tag(form, field) || ""]
          end
        ]
      end
    ]
  end

  defp make_vertical_input(form, field, field_name, type, input_opts, label_opts, opts) do
    content_tag :div, class: "col-sm-12" do
      [
        content_tag :div, class: "form-group" do
          [
            content_tag :div, label_opts do
              [humanize(field_name)]
            end,
            apply(Form, type, [form, field, input_opts]),
            EH.error_tag(form, field) || ""
          ] ++ add_description(get_description(opts))
        end
      ]
    end
  end

  def select_input(form, field, list, name \\ nil, opts \\ []) do
    validate_required =
      form
      |> input_validations(field)
      |> check_required

    type = Form.input_type(form, field)
    field_name = name || field
    label_opts = [class: "label #{validate_required}"]
    input_opts = [class: "form-control #{state_class(form, field)}"] ++ opts

    case is_horizontal_layout?(opts) do
      true ->
        make_horizontal_select_input(
          form,
          field,
          field_name,
          type,
          list,
          input_opts,
          label_opts,
          opts
        )

      _ ->
        make_vertical_select_input(
          form,
          field,
          field_name,
          type,
          list,
          input_opts,
          label_opts,
          opts
        )
    end
  end

  defp make_horizontal_select_input(
         form,
         field,
         field_name,
         type,
         list,
         input_opts,
         label_opts,
         opts
       ) do
    [
      content_tag :label, class: "col-sm-3 col-form-label" do
        [
          content_tag :div, label_opts do
            [humanize(field_name)]
          end
        ] ++ add_description(get_description(opts))
      end,
      content_tag :div, class: "col-sm-9" do
        [
          content_tag :div, class: "form-group" do
            [select(form, field, list, input_opts), EH.error_tag(form, field) || ""]
          end
        ]
      end
    ]
  end

  defp make_vertical_select_input(
         form,
         field,
         field_name,
         type,
         list,
         input_opts,
         label_opts,
         opts
       ) do
    content_tag :div, class: "col-sm-12" do
      [
        content_tag :div, class: "form-group" do
          [
            content_tag :div, label_opts do
              [humanize(field_name)]
            end,
            select(form, field, list, input_opts),
            EH.error_tag(form, field) || ""
          ] ++ add_description(get_description(opts))
        end
      ]
    end
  end

  def multi_select(form, field, list, name \\ nil, opts \\ []) do
    validate_required =
      form
      |> input_validations(field)
      |> check_required

    type = Form.input_type(form, field)
    field_name = name || field
    label_opts = [class: "label #{validate_required}"]

    input_opts =
      [
        class: "full-width w-100 form-control #{state_class(form, field)}",
        "data-init-plugin": "select2"
      ] ++ opts

    case is_horizontal_layout?(opts) do
      true ->
        make_horizontal_multi_select_input(
          form,
          field,
          field_name,
          type,
          list,
          input_opts,
          label_opts,
          opts
        )

      _ ->
        make_vertical_multi_select_input(
          form,
          field,
          field_name,
          type,
          list,
          input_opts,
          label_opts,
          opts
        )
    end
  end

  defp make_horizontal_multi_select_input(
         form,
         field,
         field_name,
         type,
         list,
         input_opts,
         label_opts,
         opts
       ) do
    input = Form.multiple_select(form, field, list, input_opts)
    hidden_input = hidden_input(form, field, value: "")
    error = EH.error_tag(form, field) || ""

    [
      content_tag :label, class: "col-sm-3 col-form-label" do
        [
          content_tag :div, label_opts do
            [humanize(field_name)]
          end
        ] ++ add_description(get_description(opts))
      end,
      content_tag :div, class: "col-sm-9" do
        [
          content_tag :div, class: "form-group" do
            [hidden_input, input, error]
          end
        ]
      end
    ]
  end

  defp make_vertical_multi_select_input(
         form,
         field,
         field_name,
         type,
         list,
         input_opts,
         label_opts,
         opts
       ) do
    input = Form.multiple_select(form, field, list, input_opts)
    hidden_input = hidden_input(form, field, value: "")
    error = EH.error_tag(form, field) || ""

    content_tag :div, class: "col-sm-12" do
      [
        content_tag :div, class: "form-group" do
          [
            content_tag :div, label_opts do
              [humanize(field_name)]
            end,
            hidden_input,
            input,
            error
          ] ++ add_description(get_description(opts))
        end
      ]
    end
  end

  def textarea_input(form, field, name \\ nil, opts \\ []) do
    validate_required =
      form
      |> input_validations(field)
      |> check_required

    type = Form.input_type(form, field)
    field_name = name || field
    label_opts = [class: "label #{validate_required}"]
    input_opts = [class: "form-control #{state_class(form, field)}"] ++ opts

    case is_horizontal_layout?(opts) do
      true ->
        make_horizontal_textarea_input(
          form,
          field,
          field_name,
          type,
          input_opts,
          label_opts,
          opts
        )

      _ ->
        make_vertical_textarea_input(form, field, field_name, type, input_opts, label_opts, opts)
    end
  end

  defp make_horizontal_textarea_input(form, field, field_name, type, input_opts, label_opts, opts) do
    [
      content_tag :label, class: "col-sm-3 col-form-label" do
        [
          content_tag :div, label_opts do
            [humanize(field_name)]
          end
        ] ++ add_description(get_description(opts))
      end,
      content_tag :div, class: "col-sm-9" do
        [
          content_tag :div, class: "form-group" do
            [textarea(form, field, input_opts), EH.error_tag(form, field) || ""]
          end
        ]
      end
    ]
  end

  defp make_vertical_textarea_input(form, field, field_name, type, input_opts, label_opts, opts) do
    content_tag :div, class: "col-sm-12" do
      [
        content_tag :div, class: "form-group" do
          [
            content_tag :div, label_opts do
              [humanize(field_name)]
            end,
            textarea(form, field, input_opts),
            EH.error_tag(form, field) || ""
          ] ++ add_description(get_description(opts))
        end
      ]
    end
  end

  def checkbox_input(form, field, name \\ nil, opts \\ []) do
    validate_required =
      form
      |> input_validations(field)
      |> check_required

    wrapper_opts = [
      class:
        "form-group form-group-default input-group cb-group #{validate_required} #{
          state_class(form, field)
        }"
    ]

    type = Form.input_type(form, field)
    field_name = name || field
    label_opts = [class: "label inline pr-3 #{validate_required}"]
    class = opts[:class] || ""
    input_opts = [class: class] ++ opts

    case is_horizontal_layout?(opts) do
      true ->
        make_horizontal_checkbox_input(
          form,
          field,
          field_name,
          type,
          input_opts,
          label_opts,
          opts
        )

      _ ->
        make_vertical_checkbox_input(form, field, field_name, type, input_opts, label_opts, opts)
    end
  end

  defp make_horizontal_checkbox_input(form, field, field_name, type, input_opts, label_opts, opts) do
    span_input =
      content_tag :label, class: "switch" do
        span = content_tag(:span, "", class: "slider round")
        input = checkbox(form, field, input_opts)
        error = EH.error_tag(form, field) || ""
        [input, span, error || ""]
      end

    [
      content_tag :label, class: "col-sm-3 col-form-label" do
        [
          content_tag :div, label_opts do
            [humanize(field_name)]
          end
        ] ++ add_description(get_description(opts))
      end,
      content_tag :div, class: "col-sm-9" do
        [
          content_tag :div, class: "form-group" do
            span_input
          end
        ]
      end
    ]
  end

  defp make_vertical_checkbox_input(form, field, field_name, type, input_opts, label_opts, opts) do
    span_input =
      content_tag :label, class: "switch" do
        span = content_tag(:span, "", class: "slider round")
        input = checkbox(form, field, input_opts)
        error = EH.error_tag(form, field) || ""
        [input, span, error || ""]
      end

    content_tag :div, class: "col-sm-12" do
      [
        content_tag :div, class: "form-group" do
          [
            content_tag :div, label_opts do
              [humanize(field_name)]
            end,
            span_input
          ] ++ add_description(get_description(opts))
        end
      ]
    end
  end

  defp state_class(form, field) do
    cond do
      # The form was not yet submitted
      !form.source.action ->
        ""

      form.errors[field] ->
        "is-invalid"

      true ->
        "is-valid"
    end
  end

  def check_required(required: true), do: "required"
  def check_required(required: true, minlength: _), do: "required"
  def check_required(required: false), do: nil
  def check_required(required: false, minlength: _), do: nil
  def check_required([]), do: nil

  defp validate_required(form, field) do
    form
    |> input_validations(field)
    |> check_required
  end

  defp form_label(form, field, name) do
    if name == "" do
      []
    else
      label_opts = [class: "d-block control-label position-relative"]
      [label(form, field, humanize(name || field), label_opts)]
    end
  end

  defp base_input(form, field, name, inputs) do
    wrapper_opts = [class: "form-group #{validate_required(form, field)}"]
    error = EH.error_tag(form, field) || ""

    content_tag :div, wrapper_opts do
      form_label(form, field, name) ++ inputs ++ [error]
    end
  end

  defp is_horizontal_layout?(opts) do
    Keyword.get(opts, :is_horizontal)
  end

  defp get_description(opts) do
    Keyword.get(opts, :description)
  end

  defp add_description(nil), do: []

  defp add_description(description) do
    [
      content_tag :div, class: "label-txt" do
        description
      end
    ]
  end
end
