defmodule TagIp.Resources.ModeleTraceur do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("modeles_traceur")
    repo(TagIp.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :nom, :string do
      allow_nil?(false)
      constraints(max_length: 100)
      public?(true)
    end

    attribute :brand, :string do
      public?(true)
    end

    attribute :reference, :string do
      allow_nil?(false)
      constraints(max_length: 50)
      public?(true)
    end

    attribute :description, :string do
      constraints(max_length: 500)
      public?(true)
    end

    # Compatibilité élargie — Électrique
    attribute :standby_current, :float do
      public?(true)
    end

    attribute :ultra_low_power, :boolean do
      default(false)
      public?(true)
    end

    # Compatibilité élargie — Connectivité et Bus de Données
    attribute :can_bus, :boolean do
      default(false)
      public?(true)
    end

    attribute :one_wire, :boolean do
      default(false)
      public?(true)
    end

    attribute :rs232, :boolean do
      default(false)
      public?(true)
    end

    attribute :rs485, :boolean do
      default(false)
      public?(true)
    end

    # Compatibilité élargie — Entrées/Sorties (I/O)
    attribute :nb_digital_inputs, :integer do
      public?(true)
    end

    attribute :nb_analog_inputs, :integer do
      public?(true)
    end

    attribute :nb_outputs, :integer do
      public?(true)
    end

    # Compatibilité élargie — Environnement et Protection Physique
    attribute :ip_rating, :string do
      public?(true)
    end

    attribute :antennes_externes, :boolean do
      default(false)
      public?(true)
    end

    # Compatibilité élargie — Intelligence Embarquée
    attribute :accelerometer, :boolean do
      default(false)
      public?(true)
    end

    attribute :buffer_memory, :integer do
      public?(true)
    end

    timestamps()
  end

  relationships do
    has_many :compatibilites, TagIp.Resources.Compatibilite

    many_to_many :types_vehicule, TagIp.Resources.TypeVehicule do
      through(TagIp.Resources.ModeleTraceurTypeVehicule)
      source_attribute_on_join_resource(:modele_traceur_id)
      destination_attribute_on_join_resource(:type_vehicule_id)
    end

    many_to_many :alimentations, TagIp.Resources.Alimentation do
      through(TagIp.Resources.ModeleTraceurAlimentation)
      source_attribute_on_join_resource(:modele_traceur_id)
      destination_attribute_on_join_resource(:alimentation_id)
    end

    many_to_many :capteurs, TagIp.Resources.Capteur do
      through(TagIp.Resources.ModeleTraceurCapteur)
      source_attribute_on_join_resource(:modele_traceur_id)
      destination_attribute_on_join_resource(:capteur_id)
    end

    has_many :model_features, TagIp.Resources.ModelFeature

    many_to_many :features, TagIp.Resources.Feature do
      through(TagIp.Resources.ModelFeature)
      source_attribute_on_join_resource(:modele_traceur_id)
      destination_attribute_on_join_resource(:feature_id)
    end

    has_many :model_ports, TagIp.Resources.ModelPort
  end

  actions do
    defaults([:read, :destroy, :update])

    # C'est cette action qui manquait !
    read :get_by_id do
      argument(:id, :uuid, allow_nil?: false)
      filter(expr(id == ^arg(:id)))
    end

    create :create do
      primary?(true)

      accept([
        :nom,
        :brand,
        :reference,
        :description,
        :nb_digital_inputs,
        :nb_analog_inputs,
        :nb_outputs,
        :ip_rating,
        :can_bus,
        :one_wire,
        :rs232,
        :rs485,
        :accelerometer,
        :buffer_memory,
        :antennes_externes,
        :ultra_low_power,
        :standby_current
      ])
    end
  end

  code_interface do
    define(:create)
    define(:read)
    define(:update)
    define(:destroy)
    # Ici, le nom de l'action (:get_by_id) doit exister dans le bloc actions ci-dessus
    define(:get_by_id, args: [:id])
  end
end
