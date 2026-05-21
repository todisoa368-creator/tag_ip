--
-- PostgreSQL database dump
--

\restrict Hf37HIz1lKxyICT0a6XrxSZ9mWhlcBa59mGa3hzBAdVnfR7KZwCLy7OtgaBPa2X

-- Dumped from database version 13.23 (Debian 13.23-0+deb11u3)
-- Dumped by pg_dump version 13.23 (Debian 13.23-0+deb11u3)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: capteurs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.capteurs (
    id uuid NOT NULL,
    slug character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: compatibilites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.compatibilites (
    id uuid NOT NULL,
    profil_montage_id uuid NOT NULL,
    modele_traceur_id uuid NOT NULL,
    score_compatibilite bigint DEFAULT 0 NOT NULL,
    details character varying(500),
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
    standby_current double precision
);


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
    organization_id uuid,
    inserted_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    inputs_requis integer,
    analog_inputs_requis integer,
    outputs_requis integer,
    ip_rating text,
    can_bus_requis boolean DEFAULT false,
    one_wire_requis boolean DEFAULT false,
    rs232_requis boolean DEFAULT false,
    rs485_requis boolean DEFAULT false,
    accelerometre_requis boolean DEFAULT false,
    buffer_requis integer,
    montage_exterieur boolean DEFAULT false,
    antenne_deportee boolean DEFAULT false,
    ultra_low_power_requis boolean DEFAULT false
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
    inserted_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


--
-- Name: types_vehicule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.types_vehicule (
    id uuid NOT NULL,
    slug character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    hashed_password character varying(255),
    confirmed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
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
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Hf37HIz1lKxyICT0a6XrxSZ9mWhlcBa59mGa3hzBAdVnfR7KZwCLy7OtgaBPa2X

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
