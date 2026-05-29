defmodule TagIpWeb.CoreComponents do
  @moduledoc """
  Provides core UI components using Tailwind CSS and daisyUI.
  """
  use Phoenix.Component
  use Gettext, backend: TagIpWeb.Gettext

  alias Phoenix.LiveView.JS

  # --- FLASH MESSAGES ---
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
  slot :inner_block

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="fixed top-4 right-4 z-50"
      {@rest}
    >
      <div class={[
        "w-80 sm:w-96 shadow-xl border-2 rounded-xl p-4 flex items-start gap-3",
        @kind == :info && "bg-blue-50 border-blue-400 text-blue-800",
        @kind == :error && "bg-red-50 border-red-500 text-red-900"
      ]}>
        <.icon
          :if={@kind == :info}
          name="hero-information-circle"
          class="size-5 shrink-0 mt-0.5 text-blue-600"
        />
        <.icon
          :if={@kind == :error}
          name="hero-exclamation-circle"
          class="size-5 shrink-0 mt-0.5 text-red-600"
        />
        <div class="flex-1">
          <p :if={@title} class="font-bold text-sm">{@title}</p>
          <p class="text-sm font-medium">{msg}</p>
        </div>
        <button
          type="button"
          class="shrink-0 p-1 rounded-lg hover:bg-black/5 transition-colors"
          aria-label={gettext("close")}
        >
          <.icon name="hero-x-mark" class="size-4 opacity-60 hover:opacity-100" />
        </button>
      </div>
    </div>
    """
  end

  # --- SIMPLE FORM ---
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :action, :string, default: nil, doc: "the action to submit the form to"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"
  attr :rest, :global, include: ~w(method name enctype multipart)
  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} action={@action} as={@as} {@rest}>
      <div class="mt-4 space-y-6">
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  # --- BUTTON ---
  attr :class, :any, default: nil
  attr :variant, :string, values: ~w(primary secondary ghost outline danger), default: "primary"
  attr :rest, :global, include: ~w(href navigate patch method download name value disabled)
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      class={[
        "inline-flex items-center justify-center gap-2 px-6 py-2.5 text-sm font-semibold rounded-xl shadow-sm transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed",
        @variant == "primary" &&
          "bg-blue-600 text-white hover:bg-blue-700 shadow-blue-500/20 hover:shadow-md focus:ring-blue-500",
        @variant == "secondary" && "bg-gray-100 text-gray-700 hover:bg-gray-200 focus:ring-gray-400",
        @variant == "ghost" &&
          "bg-transparent text-gray-600 hover:text-gray-900 hover:bg-gray-100 shadow-none focus:ring-gray-400",
        @variant == "outline" &&
          "border-2 border-gray-300 text-gray-700 hover:bg-gray-50 hover:border-gray-400 focus:ring-gray-400",
        @variant == "danger" &&
          "bg-red-600 text-white hover:bg-red-700 shadow-red-500/20 hover:shadow-md focus:ring-red-500",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # --- INPUTS ---
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values:
      ~w(checkbox color date datetime-local email file month number password search select tel text textarea time url week hidden)

  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :class, :any, default: nil
  attr :error_class, :any, default: nil
  attr :autocomplete, :string, default: nil
  attr :required, :boolean, default: false
  attr :rows, :integer, default: nil
  attr :options, :list, default: []
  attr :rest, :global

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "password"} = assigns) do
    ~H"""
    <div class="mb-4">
      <label class="block text-sm font-semibold text-gray-700 mb-1.5" for={@id}>{@label}</label>
      <input
        type="password"
        name={@name}
        id={@id}
        value={@value}
        autocomplete={@autocomplete}
        required={@required}
        class={[
          "block w-full rounded-lg border border-gray-300 bg-white px-3 py-2.5 text-sm text-gray-900 placeholder-gray-400 shadow-sm transition-colors focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 focus:outline-none",
          @errors != [] && "border-red-500 ring-red-200 focus:border-red-500 focus:ring-red-500/20",
          @class
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="mb-4">
      <label :if={@label} class="block text-sm font-semibold text-gray-700 mb-1.5" for={@id}>
        {@label}
      </label>
      <textarea
        name={@name}
        id={@id}
        rows={@rows}
        class={[
          "block w-full rounded-lg border border-gray-300 bg-white px-3 py-2.5 text-sm text-gray-900 placeholder-gray-400 shadow-sm transition-colors focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 focus:outline-none",
          @errors != [] && "border-red-500 ring-red-200 focus:border-red-500 focus:ring-red-500/20",
          @class
        ]}
        {@rest}
      >{@value}</textarea>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="mb-4">
      <label :if={@label} class="block text-sm font-semibold text-gray-700 mb-1.5" for={@id}>
        {@label}
      </label>
      <select
        name={@name}
        id={@id}
        class={[
          "block w-full rounded-lg border border-gray-300 bg-white px-3 py-2.5 text-sm text-gray-900 shadow-sm transition-colors focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 focus:outline-none",
          @errors != [] && "border-red-500 ring-red-200 focus:border-red-500 focus:ring-red-500/20",
          @class
        ]}
        {@rest}
      >
        <option
          :for={opt <- @options}
          value={elem(opt, 1)}
          selected={@value != nil && to_string(elem(opt, 1)) == to_string(@value)}
        >
          {elem(opt, 0)}
        </option>
      </select>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div class="mb-4">
      <label :if={@label} class="block text-sm font-semibold text-gray-700 mb-1.5" for={@id}>
        {@label}
      </label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        autocomplete={@autocomplete}
        required={@required}
        class={[
          "block w-full rounded-lg border border-gray-300 bg-white px-3 py-2.5 text-sm text-gray-900 placeholder-gray-400 shadow-sm transition-colors focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 focus:outline-none",
          @errors != [] && "border-red-500 ring-red-200 focus:border-red-500 focus:ring-red-500/20",
          @class
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  defp error(assigns) do
    ~H"""
    <p class="mt-1 flex gap-2 items-center text-xs font-medium text-red-600 animate-pulse">
      <.icon name="hero-exclamation-circle" class="size-4" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  # --- HEADER ---
  slot :inner_block, required: true
  slot :subtitle

  def header(assigns) do
    ~H"""
    <header class="mb-6">
      <h1 class="text-2xl font-bold text-gray-800">
        {render_slot(@inner_block)}
      </h1>
      <p :if={@subtitle != []} class="text-sm text-gray-500 mt-1">
        {render_slot(@subtitle)}
      </p>
    </header>
    """
  end

  # --- ICON ---
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js, to: selector, time: 200)
  end

  # --- SEARCH INPUT ---
  attr :value, :string, required: true
  attr :placeholder, :string, default: "Rechercher..."
  attr :class, :any, default: nil
  attr :input_class, :any, default: nil

  def search_input(assigns) do
    ~H"""
    <form phx-change="search" class={["relative mb-4", @class]}>
      <span class="absolute inset-y-0 left-0 flex items-center pl-3.5 pointer-events-none">
        <.icon name="hero-magnifying-glass" class="size-4 text-gray-400" />
      </span>
      <input
        type="text"
        name="search"
        value={@value}
        placeholder={@placeholder}
        autocomplete="off"
        class={[
          "block w-full md:w-80 pl-10 pr-4 py-2.5 text-sm bg-white border border-gray-300 rounded-xl shadow-sm placeholder-gray-400 transition-all duration-200",
          "focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20",
          "hover:border-gray-400",
          @input_class
        ]}
      />
    </form>
    """
  end

  # --- CONFIRM MODAL ---
  attr :id, :string, default: "confirm-modal"
  attr :show, :boolean, default: false
  attr :title, :string, default: "Confirmer la suppression"

  attr :message, :string,
    default: "Êtes-vous sûr de vouloir supprimer cet élément ? Cette action est irréversible."

  attr :confirm_label, :string, default: "Supprimer"
  attr :cancel_label, :string, default: "Annuler"
  attr :on_confirm, :string, default: "delete"
  attr :on_cancel, :string, default: "cancel_delete"
  slot :inner_block

  def confirm_modal(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "fixed inset-0 z-50 flex items-center justify-center transition-all duration-200",
        not @show && "hidden"
      ]}
      role="dialog"
      aria-modal="true"
    >
      <div class="fixed inset-0 bg-black/40 backdrop-blur-sm" phx-click={@on_cancel}></div>
      <div class="relative bg-white rounded-2xl shadow-2xl max-w-md w-full mx-4 p-6 transform transition-all">
        <div class="flex items-center gap-3 mb-4">
          <div class="flex-shrink-0 w-10 h-10 rounded-full bg-red-100 flex items-center justify-center">
            <.icon name="hero-exclamation-triangle" class="size-5 text-red-600" />
          </div>
          <h3 class="text-lg font-bold text-gray-900">{@title}</h3>
        </div>
        <p class="text-sm text-gray-600 mb-6">
          {render_slot(@inner_block) || @message}
        </p>
        <div class="flex justify-end gap-3">
          <button
            phx-click={@on_cancel}
            type="button"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-xl transition-colors"
          >
            {@cancel_label}
          </button>
          <button
            phx-click={@on_confirm}
            type="button"
            class="px-4 py-2 text-sm font-semibold text-white bg-red-600 hover:bg-red-700 rounded-xl transition-colors"
          >
            {@confirm_label}
          </button>
        </div>
      </div>
    </div>
    """
  end

  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(TagIpWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(TagIpWeb.Gettext, "errors", msg, opts)
    end
  end

  attr :page, :integer, required: true
  attr :page_size, :integer, required: true
  attr :total_count, :integer, required: true

  def pagination(assigns) do
    ~H"""
    <%= if @total_count > @page_size do %>
      <div class="flex justify-between items-center mt-4 px-2">
        <span class="text-sm text-gray-500">
          Affichage {(@page - 1) * @page_size + 1}- {min(@page * @page_size, @total_count)} sur {@total_count}
        </span>
        <div class="flex gap-2">
          <button
            phx-click="paginate"
            phx-value-page={@page - 1}
            disabled={@page <= 1}
            class={[
              "px-3 py-1 rounded text-sm font-medium border transition",
              @page <= 1 && "border-gray-200 text-gray-300 cursor-not-allowed",
              @page > 1 && "border-gray-300 text-gray-700 hover:bg-gray-100"
            ]}
          >
            ← Précédent
          </button>
          <button
            phx-click="paginate"
            phx-value-page={@page + 1}
            disabled={@page * @page_size >= @total_count}
            class={[
              "px-3 py-1 rounded text-sm font-medium border transition",
              @page * @page_size >= @total_count &&
                "border-gray-200 text-gray-300 cursor-not-allowed",
              @page * @page_size < @total_count && "border-gray-300 text-gray-700 hover:bg-gray-100"
            ]}
          >
            Suivant →
          </button>
        </div>
      </div>
    <% end %>
    """
  end
end
