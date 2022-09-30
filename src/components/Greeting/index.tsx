import React from 'react';
import Link from '@docusaurus/Link';
import Translate, { translate } from '@docusaurus/Translate';
import Head from '@site/src/components/Greeting/Head';
import './Greeting.css';

export default function Greeting(): JSX.Element {
  return (
    <section className="greeting-flex">
      <Head />
      <Link className="greeting-button" to="/blog"><Translate>👉Browse Blog👈</Translate></Link>
    </section>
  );
}