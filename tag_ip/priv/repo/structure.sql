--
-- PostgreSQL database dump
--

\restrict kTHclDpCiQwE0IOV6xCPIWuf64lsKcb7gSlWfcpcgICxCEU61Lvj4Q5aeQ5DpJX

-- Dumped from database version 15.12 (Homebrew)
-- Dumped by pg_dump version 17.6 (Postgres.app)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alimentations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alimentations (
    id uuid NOT NULL,
    slug character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    description text,
    category character varying(255) DEFAULT 'voltage'::character varying
);


--
-- Name: COLUMN alimentations.category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alimentations.category IS 'Catégorie: voltage ou power_type';


--
-- Name: capteurs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.capteurs (
    id uuid NOT NULL,
    slug character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    description text,
    category character varying(255)
);


--
-- Name: COLUMN capteurs.category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.capteurs.category IS 'Catégorie de capteur: energy, safety, environment, driver, vehicle_status, connectivity';


--
-- Name: compatibilites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.compatibilites (
    id uuid NOT NULL,
    profil_montage_id uuid NOT NULL,
    modele_traceur_id uuid NOT NULL,
    score_compatibilite bigint DEFAULT 0 NOT NULL,
    details text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.features (
    id uuid NOT NULL,
    slug character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    description text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: model_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.model_features (
    id uuid NOT NULL,
    modele_traceur_id uuid NOT NULL,
    feature_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: model_ports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.model_ports (
    id uuid NOT NULL,
    modele_traceur_id uuid NOT NULL,
    port_type_id uuid NOT NULL,
    pin_label character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: modeles_traceur; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modeles_traceur (
    id uuid NOT NULL,
    nom character varying(100) NOT NULL,
    reference character varying(50) NOT NULL,
    description character varying(500),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    nb_digital_inputs integer,
    nb_analog_inputs integer,
    nb_outputs integer,
    ip_rating text,
    can_bus boolean DEFAULT false,
    one_wire boolean DEFAULT false,
    rs232 boolean DEFAULT false,
    rs485 boolean DEFAULT false,
    accelerometer boolean DEFAULT false,
    buffer_memory integer,
    antennes_externes boolean DEFAULT false,
    ultra_low_power boolean DEFAULT false,
    standby_current double precision,
    brand text,
    voltage_min double precision,
    voltage_max double precision,
    bluetooth_ble boolean DEFAULT false
);


--
-- Name: COLUMN modeles_traceur.voltage_min; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.modeles_traceur.voltage_min IS 'Tension minimale supportée (V)';


--
-- Name: COLUMN modeles_traceur.voltage_max; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.modeles_traceur.voltage_max IS 'Tension maximale supportée (V)';


--
-- Name: modeles_traceur_alimentations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modeles_traceur_alimentations (
    id uuid NOT NULL,
    modele_traceur_id uuid NOT NULL,
    alimentation_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: modeles_traceur_capteurs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modeles_traceur_capteurs (
    id uuid NOT NULL,
    modele_traceur_id uuid NOT NULL,
    capteur_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: modeles_traceur_types_vehicule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modeles_traceur_types_vehicule (
    id uuid NOT NULL,
    modele_traceur_id uuid NOT NULL,
    type_vehicule_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: mounting_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mounting_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    reporting_interval text,
    object_type text,
    voltage_min double precision,
    voltage_max double precision,
    buzzer boolean DEFAULT false,
    fuel_probe_type text,
    geofence_enabled boolean DEFAULT false,
    driver_id_type text,
    organisation_id uuid,
    inserted_at timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text) NOT NULL,
    updated_at timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text) NOT NULL,
    inputs_requis integer,
    analog_inputs_requis integer,
    outputs_requis integer,
    can_bus_requis boolean DEFAULT false,
    one_wire_requis boolean DEFAULT false,
    rs232_requis boolean DEFAULT false,
    rs485_requis boolean DEFAULT false,
    accelerometre_requis boolean DEFAULT false,
    montage_exterieur boolean DEFAULT false,
    antenne_deportee boolean DEFAULT false,
    ultra_low_power_requis boolean DEFAULT false,
    bluetooth_ble_requis boolean DEFAULT false,
    modele_traceur_id uuid,
    feature_slugs text[] DEFAULT ARRAY[]::text[],
    type_vehicule_id uuid,
    alimentation_id uuid
);


--
-- Name: organisations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organisations (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    description character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: peripherals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.peripherals (
    id uuid NOT NULL,
    port_type_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: port_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.port_types (
    id uuid NOT NULL,
    slug character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    description text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: profil_montage_capteurs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profil_montage_capteurs (
    id uuid NOT NULL,
    profil_montage_id uuid NOT NULL,
    capteur_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: profil_montage_peripherals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profil_montage_peripherals (
    id uuid NOT NULL,
    profil_montage_id uuid NOT NULL,
    peripheral_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: profile_comparaisons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_comparaisons (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    feature_slugs character varying(255)[] DEFAULT ARRAY[]::character varying[] NOT NULL,
    peripheral_ids uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    compatible_tracker_ids uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    user_id integer
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: trackable_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trackable_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug text NOT NULL,
    label text NOT NULL,
    description text,
    inserted_at timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text) NOT NULL,
    updated_at timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text) NOT NULL,
    voltage_min double precision,
    voltage_max double precision
);


--
-- Name: types_vehicule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.types_vehicule (
    id uuid NOT NULL,
    slug character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    description text,
    voltage_min double precision,
    voltage_max double precision,
    inputs_requis integer,
    outputs_requis integer
);


--
-- Name: COLUMN types_vehicule.voltage_min; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.types_vehicule.voltage_min IS 'Tension minimale recommandée (V)';


--
-- Name: COLUMN types_vehicule.voltage_max; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.types_vehicule.voltage_max IS 'Tension maximale recommandée (V)';


--
-- Name: COLUMN types_vehicule.inputs_requis; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.types_vehicule.inputs_requis IS 'Nombre d''entrées numériques minimum requis';


--
-- Name: COLUMN types_vehicule.outputs_requis; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.types_vehicule.outputs_requis IS 'Nombre de sorties minimum requis';


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    hashed_password character varying(255),
    confirmed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    role character varying(255) DEFAULT 'user'::character varying NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    authenticated_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_tokens_id_seq OWNED BY public.users_tokens.id;


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Name: alimentations alimentations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alimentations
    ADD CONSTRAINT alimentations_pkey PRIMARY KEY (id);


--
-- Name: capteurs capteurs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capteurs
    ADD CONSTRAINT capteurs_pkey PRIMARY KEY (id);


--
-- Name: compatibilites compatibilites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compatibilites
    ADD CONSTRAINT compatibilites_pkey PRIMARY KEY (id);


--
-- Name: features features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.features
    ADD CONSTRAINT features_pkey PRIMARY KEY (id);


--
-- Name: model_features model_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_features
    ADD CONSTRAINT model_features_pkey PRIMARY KEY (id);


--
-- Name: model_ports model_ports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_ports
    ADD CONSTRAINT model_ports_pkey PRIMARY KEY (id);


--
-- Name: modeles_traceur_alimentations modeles_traceur_alimentations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modeles_traceur_alimentations
    ADD CONSTRAINT modeles_traceur_alimentations_pkey PRIMARY KEY (id);


--
-- Name: modeles_traceur_capteurs modeles_traceur_capteurs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modeles_traceur_capteurs
    ADD CONSTRAINT modeles_traceur_capteurs_pkey PRIMARY KEY (id);


--
-- Name: modeles_traceur modeles_traceur_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modeles_traceur
    ADD CONSTRAINT modeles_traceur_pkey PRIMARY KEY (id);


--
-- Name: modeles_traceur_types_vehicule modeles_traceur_types_vehicule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modeles_traceur_types_vehicule
    ADD CONSTRAINT modeles_traceur_types_vehicule_pkey PRIMARY KEY (id);


--
-- Name: mounting_profiles mounting_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mounting_profiles
    ADD CONSTRAINT mounting_profiles_pkey PRIMARY KEY (id);


--
-- Name: organisations organisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: peripherals peripherals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.peripherals
    ADD CONSTRAINT peripherals_pkey PRIMARY KEY (id);


--
-- Name: port_types port_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.port_types
    ADD CONSTRAINT port_types_pkey PRIMARY KEY (id);


--
-- Name: profil_montage_capteurs profil_montage_capteurs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil_montage_capteurs
    ADD CONSTRAINT profil_montage_capteurs_pkey PRIMARY KEY (id);


--
-- Name: profil_montage_peripherals profil_montage_peripherals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil_montage_peripherals
    ADD CONSTRAINT profil_montage_peripherals_pkey PRIMARY KEY (id);


--
-- Name: profile_comparaisons profile_comparaisons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_comparaisons
    ADD CONSTRAINT profile_comparaisons_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: trackable_types trackable_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trackable_types
    ADD CONSTRAINT trackable_types_pkey PRIMARY KEY (id);


--
-- Name: types_vehicule types_vehicule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.types_vehicule
    ADD CONSTRAINT types_vehicule_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_tokens users_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_pkey PRIMARY KEY (id);


--
-- Name: alimentations_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX alimentations_slug_index ON public.alimentations USING btree (slug);


--
-- Name: capteurs_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX capteurs_slug_index ON public.capteurs USING btree (slug);


--
-- Name: compatibilites_modele_traceur_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX compatibilites_modele_traceur_id_index ON public.compatibilites USING btree (modele_traceur_id);


--
-- Name: compatibilites_profil_montage_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX compatibilites_profil_montage_id_index ON public.compatibilites USING btree (profil_montage_id);


--
-- Name: features_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX features_slug_index ON public.features USING btree (slug);


--
-- Name: model_features_modele_traceur_id_feature_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX model_features_modele_traceur_id_feature_id_index ON public.model_features USING btree (modele_traceur_id, feature_id);


--
-- Name: model_ports_modele_traceur_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX model_ports_modele_traceur_id_index ON public.model_ports USING btree (modele_traceur_id);


--
-- Name: model_ports_port_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX model_ports_port_type_id_index ON public.model_ports USING btree (port_type_id);


--
-- Name: modeles_traceur_alimentations_modele_traceur_id_alimentation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX modeles_traceur_alimentations_modele_traceur_id_alimentation_id ON public.modeles_traceur_alimentations USING btree (modele_traceur_id, alimentation_id);


--
-- Name: modeles_traceur_capteurs_modele_traceur_id_capteur_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX modeles_traceur_capteurs_modele_traceur_id_capteur_id_index ON public.modeles_traceur_capteurs USING btree (modele_traceur_id, capteur_id);


--
-- Name: modeles_traceur_reference_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX modeles_traceur_reference_index ON public.modeles_traceur USING btree (reference);


--
-- Name: modeles_traceur_types_vehicule_modele_traceur_id_type_vehicule_; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX modeles_traceur_types_vehicule_modele_traceur_id_type_vehicule_ ON public.modeles_traceur_types_vehicule USING btree (modele_traceur_id, type_vehicule_id);


--
-- Name: mounting_profiles_alimentation_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mounting_profiles_alimentation_id_index ON public.mounting_profiles USING btree (alimentation_id);


--
-- Name: mounting_profiles_modele_traceur_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mounting_profiles_modele_traceur_id_index ON public.mounting_profiles USING btree (modele_traceur_id);


--
-- Name: mounting_profiles_type_vehicule_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mounting_profiles_type_vehicule_id_index ON public.mounting_profiles USING btree (type_vehicule_id);


--
-- Name: organisations_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX organisations_slug_index ON public.organisations USING btree (slug);


--
-- Name: peripherals_port_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX peripherals_port_type_id_index ON public.peripherals USING btree (port_type_id);


--
-- Name: peripherals_unique_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX peripherals_unique_name_index ON public.peripherals USING btree (name);


--
-- Name: port_types_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX port_types_slug_index ON public.port_types USING btree (slug);


--
-- Name: profil_montage_capteurs_capteur_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX profil_montage_capteurs_capteur_id_index ON public.profil_montage_capteurs USING btree (capteur_id);


--
-- Name: profil_montage_capteurs_profil_montage_id_capteur_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX profil_montage_capteurs_profil_montage_id_capteur_id_index ON public.profil_montage_capteurs USING btree (profil_montage_id, capteur_id);


--
-- Name: profil_montage_peripherals_peripheral_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX profil_montage_peripherals_peripheral_id_index ON public.profil_montage_peripherals USING btree (peripheral_id);


--
-- Name: profil_montage_peripherals_profil_montage_id_peripheral_id_inde; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX profil_montage_peripherals_profil_montage_id_peripheral_id_inde ON public.profil_montage_peripherals USING btree (profil_montage_id, peripheral_id);


--
-- Name: trackable_types_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX trackable_types_slug_index ON public.trackable_types USING btree (slug);


--
-- Name: types_vehicule_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX types_vehicule_slug_index ON public.types_vehicule USING btree (slug);


--
-- Name: unique_compatibilite; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_compatibilite ON public.compatibilites USING btree (profil_montage_id, modele_traceur_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: compatibilites compatibilites_modele_traceur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compatibilites
    ADD CONSTRAINT compatibilites_modele_traceur_id_fkey FOREIGN KEY (modele_traceur_id) REFERENCES public.modeles_traceur(id) ON DELETE CASCADE;


--
-- Name: compatibilites compatibilites_profil_montage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compatibilites
    ADD CONSTRAINT compatibilites_profil_montage_id_fkey FOREIGN KEY (profil_montage_id) REFERENCES public.mounting_profiles(id) ON DELETE CASCADE;


--
-- Name: model_features model_features_feature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_features
    ADD CONSTRAINT model_features_feature_id_fkey FOREIGN KEY (feature_id) REFERENCES public.features(id) ON DELETE CASCADE;


--
-- Name: model_features model_features_modele_traceur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_features
    ADD CONSTRAINT model_features_modele_traceur_id_fkey FOREIGN KEY (modele_traceur_id) REFERENCES public.modeles_traceur(id) ON DELETE CASCADE;


--
-- Name: model_ports model_ports_modele_traceur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_ports
    ADD CONSTRAINT model_ports_modele_traceur_id_fkey FOREIGN KEY (modele_traceur_id) REFERENCES public.modeles_traceur(id) ON DELETE CASCADE;


--
-- Name: model_ports model_ports_port_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_ports
    ADD CONSTRAINT model_ports_port_type_id_fkey FOREIGN KEY (port_type_id) REFERENCES public.port_types(id) ON DELETE CASCADE;


--
-- Name: modeles_traceur_alimentations modeles_traceur_alimentations_alimentation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modeles_traceur_alimentations
    ADD CONSTRAINT modeles_traceur_alimentations_alimentation_id_fkey FOREIGN KEY (alimentation_id) REFERENCES public.alimentations(id) ON DELETE CASCADE;


--
-- Name: modeles_traceur_alimentations modeles_traceur_alimentations_modele_traceur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modeles_traceur_alimentations
    ADD CONSTRAINT modeles_traceur_alimentations_modele_traceur_id_fkey FOREIGN KEY (modele_traceur_id) REFERENCES public.modeles_traceur(id) ON DELETE CASCADE;


--
-- Name: modeles_traceur_capteurs modeles_traceur_capteurs_capteur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modeles_traceur_capteurs
    ADD CONSTRAINT modeles_traceur_capteurs_capteur_id_fkey FOREIGN KEY (capteur_id) REFERENCES public.capteurs(id) ON DELETE CASCADE;


--
-- Name: modeles_traceur_capteurs modeles_traceur_capteurs_modele_traceur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modeles_traceur_capteurs
    ADD CONSTRAINT modeles_traceur_capteurs_modele_traceur_id_fkey FOREIGN KEY (modele_traceur_id) REFERENCES public.modeles_traceur(id) ON DELETE CASCADE;


--
-- Name: modeles_traceur_types_vehicule modeles_traceur_types_vehicule_modele_traceur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modeles_traceur_types_vehicule
    ADD CONSTRAINT modeles_traceur_types_vehicule_modele_traceur_id_fkey FOREIGN KEY (modele_traceur_id) REFERENCES public.modeles_traceur(id) ON DELETE CASCADE;


--
-- Name: modeles_traceur_types_vehicule modeles_traceur_types_vehicule_type_vehicule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modeles_traceur_types_vehicule
    ADD CONSTRAINT modeles_traceur_types_vehicule_type_vehicule_id_fkey FOREIGN KEY (type_vehicule_id) REFERENCES public.types_vehicule(id) ON DELETE CASCADE;


--
-- Name: mounting_profiles mounting_profiles_alimentation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mounting_profiles
    ADD CONSTRAINT mounting_profiles_alimentation_id_fkey FOREIGN KEY (alimentation_id) REFERENCES public.alimentations(id) ON DELETE SET NULL;


--
-- Name: mounting_profiles mounting_profiles_modele_traceur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mounting_profiles
    ADD CONSTRAINT mounting_profiles_modele_traceur_id_fkey FOREIGN KEY (modele_traceur_id) REFERENCES public.modeles_traceur(id) ON DELETE SET NULL;


--
-- Name: mounting_profiles mounting_profiles_organisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mounting_profiles
    ADD CONSTRAINT mounting_profiles_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES public.organisations(id) ON DELETE SET NULL;


--
-- Name: mounting_profiles mounting_profiles_type_vehicule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mounting_profiles
    ADD CONSTRAINT mounting_profiles_type_vehicule_id_fkey FOREIGN KEY (type_vehicule_id) REFERENCES public.types_vehicule(id) ON DELETE SET NULL;


--
-- Name: peripherals peripherals_port_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.peripherals
    ADD CONSTRAINT peripherals_port_type_id_fkey FOREIGN KEY (port_type_id) REFERENCES public.port_types(id) ON DELETE CASCADE;


--
-- Name: profil_montage_capteurs profil_montage_capteurs_capteur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil_montage_capteurs
    ADD CONSTRAINT profil_montage_capteurs_capteur_id_fkey FOREIGN KEY (capteur_id) REFERENCES public.capteurs(id) ON DELETE CASCADE;


--
-- Name: profil_montage_capteurs profil_montage_capteurs_profil_montage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil_montage_capteurs
    ADD CONSTRAINT profil_montage_capteurs_profil_montage_id_fkey FOREIGN KEY (profil_montage_id) REFERENCES public.mounting_profiles(id) ON DELETE CASCADE;


--
-- Name: profil_montage_peripherals profil_montage_peripherals_peripheral_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil_montage_peripherals
    ADD CONSTRAINT profil_montage_peripherals_peripheral_id_fkey FOREIGN KEY (peripheral_id) REFERENCES public.peripherals(id) ON DELETE CASCADE;


--
-- Name: profil_montage_peripherals profil_montage_peripherals_profil_montage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil_montage_peripherals
    ADD CONSTRAINT profil_montage_peripherals_profil_montage_id_fkey FOREIGN KEY (profil_montage_id) REFERENCES public.mounting_profiles(id) ON DELETE CASCADE;


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict kTHclDpCiQwE0IOV6xCPIWuf64lsKcb7gSlWfcpcgICxCEU61Lvj4Q5aeQ5DpJX

INSERT INTO public."schema_migrations" (version) VALUES (20260504140800);
INSERT INTO public."schema_migrations" (version) VALUES (20260504140801);
INSERT INTO public."schema_migrations" (version) VALUES (20260504140802);
INSERT INTO public."schema_migrations" (version) VALUES (20260505094407);
INSERT INTO public."schema_migrations" (version) VALUES (20260505121955);
INSERT INTO public."schema_migrations" (version) VALUES (20260506084629);
INSERT INTO public."schema_migrations" (version) VALUES (20260512071423);
INSERT INTO public."schema_migrations" (version) VALUES (20260513080051);
INSERT INTO public."schema_migrations" (version) VALUES (20260513100620);
INSERT INTO public."schema_migrations" (version) VALUES (20260513102505);
INSERT INTO public."schema_migrations" (version) VALUES (20260515053318);
INSERT INTO public."schema_migrations" (version) VALUES (20260518114527);
INSERT INTO public."schema_migrations" (version) VALUES (20260521082112);
INSERT INTO public."schema_migrations" (version) VALUES (20260601065805);
INSERT INTO public."schema_migrations" (version) VALUES (20260601070608);
INSERT INTO public."schema_migrations" (version) VALUES (20260601074058);
INSERT INTO public."schema_migrations" (version) VALUES (20260601085211);
INSERT INTO public."schema_migrations" (version) VALUES (20260601123534);
INSERT INTO public."schema_migrations" (version) VALUES (20260604112305);
INSERT INTO public."schema_migrations" (version) VALUES (20260605054531);
INSERT INTO public."schema_migrations" (version) VALUES (20260605072000);
INSERT INTO public."schema_migrations" (version) VALUES (20260608070531);
INSERT INTO public."schema_migrations" (version) VALUES (20260608105806);
INSERT INTO public."schema_migrations" (version) VALUES (20260609104943);
INSERT INTO public."schema_migrations" (version) VALUES (20260609112821);
INSERT INTO public."schema_migrations" (version) VALUES (20260610091711);
INSERT INTO public."schema_migrations" (version) VALUES (20260610111351);
INSERT INTO public."schema_migrations" (version) VALUES (20260610113209);
INSERT INTO public."schema_migrations" (version) VALUES (20260610114505);
INSERT INTO public."schema_migrations" (version) VALUES (20260611120000);
INSERT INTO public."schema_migrations" (version) VALUES (20260612064325);
INSERT INTO public."schema_migrations" (version) VALUES (20260713064211);
